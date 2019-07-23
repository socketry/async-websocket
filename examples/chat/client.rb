#!/usr/bin/env ruby

require 'async'
require 'async/io/stream'
require 'async/http/url_endpoint'
require_relative '../../lib/async/websocket/client'

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "ws://localhost:8080"

Async do |task|
	stdin = Async::IO::Stream.new(
		Async::IO::Generic.new($stdin)
	)
	
	endpoint = Async::HTTP::URLEndpoint.parse(URL)
	
	endpoint.connect do |socket|
		connection = Async::WebSocket::Client.new(socket, URL)
		
		input_task = task.async do
			while line = stdin.read_until("\n")
				puts "Sending message: #{line}"
				connection.send_message({text: line})
			end
		end
		
		while message = connection.next_message
			puts ": #{message.inspect}"
		end
	ensure
		input_task&.stop
	end
end
