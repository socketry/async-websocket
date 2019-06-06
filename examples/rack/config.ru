#!/usr/bin/env -S falcon serve --bind http://127.0.0.1:7070 --count 1 -c

require 'async/websocket/adapters/rack'

app = lambda do |env|
	Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
		p [env["REMOTE_ADDR"], "connected", env["VERSION"]]
		message = connection.read
		p message
		connection.write message
	end
end

run app
