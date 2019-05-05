#!/usr/bin/env ruby

require 'async'
require 'async/io/stream'
require 'async/http/url_endpoint'
require_relative '../../lib/async/websocket/client'

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "http://127.0.0.1:8080"
ENDPOINT = Async::HTTP::URLEndpoint.parse(URL)

Async do |task|
	stdin = Async::IO::Stream.new(
		Async::IO::Generic.new($stdin)
	)
	
	Async::WebSocket::Client.open(ENDPOINT) do |connection|
		input_task = task.async do
			while line = stdin.read_until("\n")
				connection.send_message({text: line})
			end
		end
		
		puts "Connected..."
		while message = connection.next_message
			puts "> #{message.inspect}"
		end
	ensure
		input_task&.stop
	end
end
