#!/usr/bin/env falcon serve --concurrency 1 -c

require 'async/websocket/server'

require 'async/actor'
require 'set'

bus = Async::Actor::Bus::Redis.new

class Room
	def initialize
		@connections = Set.new
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
end

bus.supervise(:room) do
	Room.new
end

run lambda {|env|
	room = bus[:room]
	
	Async::WebSocket::Server.open(env) do |connection|
		begin
			room.connect(connection)
			
			while message = connection.next_message
				room.each do |connection|
					connection.send_message(message)
				end
			end
		rescue
			room.disconnect(connection)
		end
	end
	
	Async::Task.current.sleep(0.1)
	[200, {}, ["Hello World"]]
}
