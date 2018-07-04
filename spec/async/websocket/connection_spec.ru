
require 'async/websocket/server'

class Upgrade
	def initialize(app)
		@app = app
	end
	
	def call(env)
		result = Async::WebSocket::Server.open(env) do |server|
			read, write = IO.pipe
			
			Process.spawn("ls -lah", :out => write)
			write.close
			
			read.each_line do |line|
				server.send_text(line)
			end
			
		end or @app.call(env)
	end
end

use Upgrade

run lambda {|env| [404, {}, []]}
