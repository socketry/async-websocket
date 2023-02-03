#!/usr/bin/env -S falcon serve --bind http://localhost:7070 --count 1 -c

require 'async/websocket/adapters/rack'
require 'set'

$connections = Set.new

class ClosedLogger
	def initialize(app)
		@app = app
	end

	def call(env)
		response = @app.call(env)

		response[2] = Rack::BodyProxy.new(response[2]) do
			Console.logger.debug(self, "Connection closed!")
		end

		return response
	end
end

# This wraps our response in a body proxy which ensures Falcon can handle the response not being an instance of `Protocol::HTTP::Body::Readable`.
use ClosedLogger

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
		rescue => error
			Console.logger.error(self, error)
		ensure
			$connections.delete(connection)
		end
	end or [200, {}, ["Hello World"]]
}
