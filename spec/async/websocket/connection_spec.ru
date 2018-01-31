
require 'async/websocket'

class Upgrade
	def initialize(app)
		@app = app
	end
	
	def call(env)
		if Async::WebSocket?(env)
			Async::WebSocket.open(env) do |connection|
				read, write = IO.pipe
				
				Process.spawn("ls -lah", :out => write)
				write.close
				
				read.each_line do |line|
					connection.text(line)
				end
				
				connection.close
			end
		else
			@app.call(env)
		end
	end
end

use Upgrade

run lambda {|env| [404, {}, []]}
