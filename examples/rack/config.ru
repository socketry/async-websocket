#!/usr/bin/env -S falcon serve --bind http://127.0.0.1:7070 --count 1 -c

require 'async/websocket/adapters/rack'

app = lambda do |env|
	Async::WebSocket::Adapters::Rack.open(env) do |connection|
		message = connection.read
		connection.write message.reverse
	end
end

run app
