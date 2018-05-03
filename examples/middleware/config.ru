#!/usr/bin/env falcon --verbose serve --concurrency 1 -c

require 'async/websocket/server'

Async.logger.level = Logger::DEBUG

class RackUpgrade
	def initialize(app)
		@app = app
	end
	
	def call(env)
		if ::WebSocket::Driver.websocket?(env)
			env['rack.upgrade?'] = :websocket
			
			response = @app.call(env)
			
			if handler = env['rack.upgrade']
				Async::WebSocket::Server.open(env) do |connection|
					begin
						while event = connection.next_event
							if event.is_a? ::WebSocket::Driver::OpenEvent
								handler.on_open(connection) if handler.respond_to? :on_open
							elsif event.is_a? ::WebSocket::Driver::MessageEvent
								handler.on_message(connection, JSON.parse(event.data))
							elsif event.is_a? ::WebSocket::Driver::CloseEvent
								handler.on_close(connection) if handler.respond_to? :on_close
							end
						end
					ensure
						handler.on_shutdown(connection) if handler.respond_to? :on_shutdown
					end
				end
			end
		else
			return @app.call(env)
		end
	end
end

class Chatty
	def initialize
		@connections = Set.new
	end
	
	def on_open(connection)
		Async.logger.info(self) {"on_open: #{connection}"}
		@connections << connection
	end
	
	def on_message(connection, message)
		Async.logger.info(self) {"on_message: #{connection} -> #{message}"}
		
		@connections.each do |connection|
			connection.send_message(message)
		end
	end
	
	def on_shutdown(connection)
		Async.logger.info(self) {"on_shutdown: #{connection}"}
		@connections.delete(connection)
		
		@connections.each do |connection|
			connection.send_message(message)
		end
	end
end

use RackUpgrade

CHATTY = Chatty.new

run lambda {|env|
	env['rack.upgrade'] = CHATTY
	
	return [200, {}, []]
}
