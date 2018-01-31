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

require 'websocket/driver'

module Async
	module WebSocket
		# This is a basic synchronous websocket client:
		class Client
			EVENTS = [:open, :message, :error, :close]
			
			def initialize(socket, url: "ws://.")
				@socket = socket
				@url = url
				
				@driver = ::WebSocket::Driver.client(self)
				
				@queue = []
				
				EVENTS.each do |event|
					@driver.on(event) do
						@queue.push event
					end
				end
				
				@driver.start
			end
			
			attr :driver
			attr :url
			
			def next_event
				while @queue.empty?
					data = @socket.recv(1024)
					
					return nil if data.empty?
					
					@driver.parse(data)
				end
				
				@queue.shift
			end
			
			def write(data)
				@socket.write(data)
			end
			
			def close
				@driver.close
			end
		end
	end
end
