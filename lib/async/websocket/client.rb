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
			
			# @return [Client] a client which can be used to establish websocket connections to the given endpoint.
			def self.open(endpoint, **options, &block)
				client = self.new(HTTP::Client.new(endpoint, **options), mask: true)
				
				return client unless block_given?
				
				begin
					yield client
				ensure
					client.close
				end
			end
			
			# @return [Connection] an open websocket connection to the given endpoint.
			def self.connect(endpoint, *args, **options, &block)
				client = self.open(endpoint, *args)
				connection = client.connect(endpoint.authority, endpoint.path, **options)
					
				return connection unless block_given?
					
				begin
					yield connection
				ensure
					connection.close
					client.close
				end
			end
			
			def initialize(client, **options)
				super(client)
				
				@options = options
			end
			
			class Framer < ::Protocol::WebSocket::Framer
				def initialize(pool, connection, stream)
					super(stream)
					@pool = pool
					@connection = connection
				end
				
				def close
					super
					
					if @pool
						@pool.release(@connection)
						@pool = nil
						@connection = nil
					end
				end
			end
			
			def connect(authority, path, headers: nil, handler: Connection, **options, &block)
				headers = ::Protocol::HTTP::Headers[headers]
				request = Request.new(nil, authority, path, headers, **options)
				
				pool = @delegate.pool
				connection = pool.acquire
				
				response = request.call(connection)
				
				unless response.stream?
					raise ProtocolError, "Failed to negotiate connection: #{response.status}"
				end
				
				protocol = response.headers[SEC_WEBSOCKET_PROTOCOL]&.first
				stream = response.stream
				response = nil
				
				framer = Framer.new(pool, connection, stream)
				connection = nil
				
				handler.call(framer, protocol, **@options, &block)
			ensure
				pool.release(connection) if connection
			end
		end
	end
end
