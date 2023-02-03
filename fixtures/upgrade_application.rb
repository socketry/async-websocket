# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'async/websocket/adapters/rack'

class UpgradeApplication
	def initialize(app)
		@app = app
	end
	
	def call(env)
		Async::WebSocket::Adapters::Rack.open(env) do |connection|
			read, write = IO.pipe
			
			Process.spawn("ls -lah", :out => write)
			write.close
			
			read.each_line do |line|
				connection.send_text(line)
			end
			
			# Gracefully close the connection:
			connection.close
		end or @app.call(env)
	end
end
