#!/usr/bin/env ruby

require 'async'
require 'async/logger'
require 'async/clock'
require 'async/io/stream'
require 'async/http/url_endpoint'
require 'async/websocket/client'

require 'samovar'

class Command < Samovar::Command
	options do
		option "-c/--count <integer>", "The number of connections to make", default: 1000, type: Integer
		option "--bind <address>", "The local address to bind to before making a connection"
		option "--connect <string>", "The remote server to connect to", default: "ws://localhost:8080"
	end
	
	def local_address
		if bind = @options[:bind]
			Async::IO::Address.tcp(bind, 0)
		end
	end
	
	def call
		endpoint = Async::HTTP::URLEndpoint.parse(@options[:connect], local_address: self.local_address)
		count = @options[:count]
		
		Async do |task|
			task.logger.info!
			
			count.times do |i|
				task.async do
					endpoint.connect do |socket|
						connection = Async::WebSocket::Client.new(socket, @options[:connect])
						
						# connection.send_message({
						# 	user: "user #{i}",
						# 	status: "connected",
						# })
						
						while message = connection.next_message
							pp message
						end
					end
				end
			end
			
			Async.logger.info "Connecting #{count} clients..."
		end
	end
end

Command.call
