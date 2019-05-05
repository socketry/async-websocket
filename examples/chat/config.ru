#!/usr/bin/env -S falcon serve --bind http://127.0.0.1:8080 --count 1 -c

require_relative '../../lib/async/websocket/server/rack'
require 'async/clock'
require 'async/semaphore'
require 'async/logger'

require 'set'

GC.disable

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
	
	def allocations
		counts = Hash.new{|h,k| h[k] = 0}
		
		ObjectSpace.each_object do |object|
			counts[object.class] += 1
		end
		
		return counts
	end
	
	def command(code)
		Async.logger.warn self, "eval(#{code})"
		
		eval(code)
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
		Async::WebSocket::Server::Rack.open(env) do |connection|
			begin
				self.connect(connection)
				
				puts "Waiting for messages..."
				while message = connection.next_message
					if message["text"] =~ /^\/(.*?)$/
						begin
							result = self.command($1)
							
							if result.is_a? Hash
								connection.send_message(result)
							else
								connection.send_message({result: result.inspect})
							end
						rescue
							connection.send_message({error: $!.inspect})
						end
					else
						self.broadcast(message)
					end
				end
			ensure
				puts "Connection finished..."
				self.disconnect(connection)
			end
		end
	end
end

run Room.new
