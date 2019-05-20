#!/usr/bin/env -S falcon serve --bind http://localhost:7070 --count 1 -c

require 'async/websocket/adapters/rack'
require 'set'

$connections = Set.new

run lambda {|env|
	Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
		$connections << connection
		
		begin
			while message = connection.read
				$connections.each do |connection|
					connection.write(message)
					connection.flush
				end
			end
		ensure
			$connections.delete(connection)
		end
	end or [200, {}, ["Hello World"]]
}
