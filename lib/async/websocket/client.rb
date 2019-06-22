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
require_relative 'connection'

require 'protocol/websocket/headers'
require 'protocol/http/middleware'

require 'async/http/client'

module Async
	module WebSocket
		# This is a basic synchronous websocket client:
		class Client < ::Protocol::HTTP::Middleware
			include ::Protocol::WebSocket::Headers
			
			def self.open(endpoint, *args, &block)
				client = self.new(HTTP::Client.new(endpoint, *args), mask: endpoint.secure?)
				
				return client unless block_given?
				
				begin
					yield client
				ensure
					client.close
				end
			end
			
			def self.connect(endpoint, *args, **options, &block)
				self.open(endpoint, *args) do |client|
					connection = client.connect(endpoint.path, **options)
					
					return connection unless block_given?
					
					begin
						yield connection
					ensure
						connection.close
					end
				end
			end
			
			def initialize(delegate, **options)
				super(delegate)
				
				@options = options
			end
			
			def connect(path, headers: [], handler: Connection, **options)
				request = Request.new(nil, nil, path, headers, **options)
				
				response = self.call(request)
				
				unless response.stream?
					raise ProtocolError, "Failed to negotiate connection: #{response.status}"
				end
				
				protocol = response.headers[SEC_WEBSOCKET_PROTOCOL]&.first
				framer = Protocol::WebSocket::Framer.new(response.stream)
				
				connection = handler.call(framer, protocol, **@options)
				
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
