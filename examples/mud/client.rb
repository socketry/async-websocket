#!/usr/bin/env ruby

require 'async'
require 'async/io/stream'
require 'async/http/endpoint'
require 'async/websocket/client'

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "http://127.0.0.1:7070"

Async do |task|
	stdin = Async::IO::Stream.new(
		Async::IO::Generic.new($stdin)
	)
	
	endpoint = Async::HTTP::Endpoint.parse(URL)
	
	Async::WebSocket::Client.open(endpoint) do |connection|
		task.async do
			$stdout.write "> "
			
			while line = stdin.read_until("\n")
				connection.write({input: line})
				connection.flush
				
				$stdout.write "> "
			end
		end
		
		while message = connection.read
			$stdout.puts message
		end
	end
end
