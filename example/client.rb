#!/usr/bin/env ruby

require 'async/reactor'
require 'async/io/stream'
require 'async/http/url_endpoint'
require 'async/websocket/client'

URL = ARGV.pop
USER = ARGV.pop

Async::Reactor.run do |task|
	endpoint = Async::HTTP::URLEndpoint.parse(URL)
	
	endpoint.connect do |socket|
		connection = Async::WebSocket::Client.new(socket, URL)
		
		connection.send_message({
			user: USER,
			status: "connected",
		})
		
		task.async do
			stdin = Async::IO::Stream.new(
				Async::IO::Generic.new($stdin)
			)
			
			puts "Waiting for input..."
			while line = stdin.read_until("\n")
				puts "Sending text: #{line}"
				connection.send_message({
					user: USER,
					text: line,
				})
			end
		end
		
		while message = connection.next_message
			puts "From server: #{message.inspect}"
		end
	end
end
