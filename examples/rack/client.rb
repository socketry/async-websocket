#!/usr/bin/env ruby

require 'async'
require 'async/io/stream'
require 'async/http/endpoint'
require 'async/websocket/client'

URL = ARGV.pop || "http://127.0.0.1:7070"

Async do |task|
	endpoint = Async::HTTP::Endpoint.parse(URL)
	
	Async::WebSocket::Client.connect(endpoint) do |connection|
		connection.write ["Hello World"]
		
		while message = connection.read
			p message
		end
	end
end
