
require 'utopia'
require 'async/websocket'

class LogRequest
	def initialize(app)
		@app = app
	end
	
	def call(env)
		Async.logger.debug("Server: #{env.inspect}")
		
		@app.call(env)
	end
end

use LogRequest

use Utopia::Controller, root: File.expand_path('../pages', __FILE__)

run lambda {|env| [404, {}, []]}
