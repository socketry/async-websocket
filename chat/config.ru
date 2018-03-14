#!/usr/bin/env falcon serve --concurrency 1 -c

require 'async/websocket/server'

Message = Struct.new(:user, :contents, :created_at)

$connections = []

run lambda {|env|
	Async::WebSocket::Server.open(env) do |connection|
		$connections << connection
		
		while message = connection.next_message
			$connections.each do |connection|
				connection.send_message(message)
			end
		end
	end
	
	[200, {}, ["Hello World"]]
}
