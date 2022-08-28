#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'async'
require 'async/semaphore'
require 'async/clock'
require 'async/io/stream'
require 'async/http/endpoint'
require 'protocol/websocket/json_message'
require_relative '../../lib/async/websocket/client'

require 'samovar'

# GC.disable
GC::Profiler.enable

class Command < Samovar::Command
	options do
		option "-c/--count <integer>", "The total number of connections to make.", default: 1000, type: Integer
		option "--bind <address>", "The local address to bind to before making a connection."
		option "--connect <string>", "The remote server to connect to.", default: "https://localhost:8080"
		
		option "-s/--semaphore <integer>", "The number of simultaneous connections to perform."
	end
	
	def local_address
		if bind = @options[:bind]
			Async::IO::Address.tcp(bind, 0)
		end
	end
	
	def call
		endpoint = Async::HTTP::Endpoint.parse(@options[:connect])
		# endpoint = endpoint.each.first
		
		count = @options[:count]
		
		connections = Async::Queue.new
		
		Async do |task|
			task.async do |subtask|
				while connection = connections.dequeue
					subtask.async(connection) do |subtask, connection|
						while message = connection.read
							if message = Protocol::WebSocket::JSONMessage.wrap(message)
								puts "> #{message.to_h}"
							end
						end
					ensure
						connection.close
					end
				end
				
				GC.start
			end
			
			client = Async::WebSocket::Client.open(endpoint)
			start_time = Async::Clock.now
			
			progress = Console.logger.progress(client, count)
			
			count.times do |i|
				connections.enqueue(client.connect(endpoint.authority, endpoint.path))
				
				progress.increment
				
				if (i % 10000).zero?
					count = i+1
					duration = Async::Clock.now - start_time
					Console.logger.info(self) {"Made #{count} connections: #{(count/duration).round(2)} connections/second..."}
				end
				
				# if (i % 10000).zero?
				# 	duration = Async::Clock.measure{GC.start(full_mark: false, immediate_sweep: false)}
				# 	Console.logger.info(self) {"GC.start duration=#{duration.round(2)}s GC.count=#{GC.count}"}
				# end
			end
			
			connections.enqueue(nil)
			
			Console.logger.info(self) {"Finished top level connection loop..."}
			
			GC::Profiler.report
		end
	end
end

Command.call
