# Copyright, 2015, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'websocket/version'
require 'websocket/driver'

module Async
	def self.WebSocket?(env)
		::WebSocket::Driver.websocket?(env)
	end
	
	module WebSocket
		class Connection
			READ_BUFFER_SIZE = 1024*8
			
			attr_reader :env, :url
			
			def initialize(env, io)
				@env = env
				@io = io
				
				scheme = Rack::Request.new(env).ssl? ? 'wss:' : 'ws:'
				@url = "#{scheme}//#{env['HTTP_HOST']}#{env['REQUEST_URI']}"
				
				@driver = ::WebSocket::Driver.rack(self)
				@running = false
			end
			
			def write(string)
				@io.write(string)
			end
			
			def read
				@driver.parse(@io.read(READ_BUFFER_SIZE))
			end
			
			def run(&handler)
				@running = true
				
				@driver.on(:close) do
					@running = false
				end
				
				@driver.on(:open) do
					yield @driver if block_given?
				end
				
				@driver.start
				
				while @running
					self.read
				end
			end
		end
		
		def self.open(env)
			if ::WebSocket::Driver.websocket?(env)
				env['rack.hijack'].call
				
				connection = Connection.new(env, env['rack.hijack_io'])
				
				connection.run do |driver|
					yield driver
				end
			end
		end
	end
end
