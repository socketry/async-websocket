#!/usr/bin/env -S falcon serve --bind http://localhost:7070 --count 1 -c

require 'async/websocket/server/rack'
require 'set'

$connections = Set.new

run lambda {|env|
	Async::WebSocket::Server::Rack.open(env, supported_protocols: ['ws']) do |connection|
		$connections << connection
		
		while message = connection.next_message
			$connections.each do |connection|
				connection.send_message(message)
				connection.flush
			end
		end
	ensure
		$connections.delete(connection)
	end or [200, {}, ["Hello World"]]
}
