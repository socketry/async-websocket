#!/usr/bin/env -S falcon serve --bind http://localhost:8080 --count 1 -c

require_relative '../../lib/async/websocket/server'
require 'async/clock'
require 'async/semaphore'
require 'async/logger'

require 'set'

class Room
	def initialize
		@connections = Set.new
		@semaphore = Async::Semaphore.new(512)
	end
	
	def connect connection
		@connections << connection
	end
	
	def disconnect connection
		@connections.delete(connection)
	end
	
	def each(&block)
		@connections.each(&block)
	end
	
	def broadcast(message)
		Async.logger.info "Broadcast: #{message.inspect}"
		start_time = Async::Clock.now
		
		@connections.each do |connection|
			@semaphore.async do
				connection.send_message(message)
			end
		end
		
		end_time = Async::Clock.now
		Async.logger.info "Duration: #{(end_time - start_time).round(3)}s for #{@connections.count} connected clients."
	end
	
	def call(env)
		Async::WebSocket::Server.open(env) do |connection|
			begin
				self.connect(connection)
				
				while message = connection.next_message
					self.broadcast(message)
				end
			ensure
				self.disconnect(connection)
			end
		end
	end
end

run Room.new
