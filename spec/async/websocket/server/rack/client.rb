#!/usr/bin/env ruby

require 'async'
require 'async/io/stream'
require 'async/http/endpoint'
require 'async/websocket/client'

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "http://localhost:7070"

Async do |task|
	stdin = Async::IO::Stream.new(
		Async::IO::Generic.new($stdin)
	)
	
	endpoint = Async::HTTP::Endpoint.parse(URL)
	headers = {'token' => 'wubalubadubdub'}
	
	Async::WebSocket::Client.open(endpoint, headers: headers) do |connection|
		input_task = task.async do
			while line = stdin.read_until("\n")
				connection.write({user: USER, text: line})
				connection.flush
			end
		end
		
		connection.write({
			user: USER,
			status: "connected",
		})
		
		while message = connection.read
			puts message.inspect
		end
	ensure
		input_task&.stop
	end
end