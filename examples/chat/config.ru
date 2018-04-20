#!/usr/bin/env falcon serve --concurrency 1 -c

require 'async/websocket/server'

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
	
	Async::Task.current.sleep(0.1)
	[200, {}, ["Hello World"]]
}
