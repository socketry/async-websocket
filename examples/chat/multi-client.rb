#!/usr/bin/env ruby

require 'async'
require 'async/logger'
require 'async/clock'
require 'async/io/stream'
require 'async/http/url_endpoint'
require 'async/websocket/client'

Async.logger.info!

COUNT = 5000
URL = ARGV.pop || "ws://localhost:9292"
endpoint = Async::HTTP::URLEndpoint.parse(URL)

Async do |task|
	start_time = Async::Clock.now
	
	COUNT.times do |i|
		task.async do
			endpoint.connect do |socket|
				connection = Async::WebSocket::Client.new(socket, URL)
				
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
	
	end_time = Async::Clock.now
	Async.logger.info "Connected #{COUNT} clients."
end
