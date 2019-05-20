# frozen_string_literals: true
#
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

require_relative 'request'

require 'protocol/websocket/headers'

require 'async/http/middleware'
require 'async/http/body'

module Async
	module WebSocket
		# This is a basic synchronous websocket client:
		class Client < HTTP::Middleware
			include ::Protocol::WebSocket::Headers
			
			def self.open(*args, &block)
				client = self.new(HTTP::Client.new(*args))
				
				return client unless block_given?
				
				begin
					yield client
				ensure
					client.close
				end
			end
			
			def connect(path, headers: [], handler: Connection, **options)
				request = Request.new(nil, nil, path, headers, **options)
				
				response = self.call(request)
				
				unless Array(response.protocol).include?(PROTOCOL)
					raise ProtocolError, "Unsupported protocol: #{response.protocol}"
				end
				
				protocol = response.headers[SEC_WEBSOCKET_PROTOCOL]&.first
				framer = Protocol::WebSocket::Framer.new(response.stream)
				connection = handler.call(framer, protocol)
				
				return connection unless block_given?
				
				begin
					yield connection
				ensure
					connection.close
				end
			end
		end
	end
end
