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

require 'protocol/http/request'
require 'protocol/http/headers'
require 'protocol/websocket/headers'
require 'protocol/http/body/readable'

module Async
	module WebSocket
		# This is required for HTTP/1.x to upgrade the connection to the WebSocket protocol.
		# See https://tools.ietf.org/html/rfc8441 for more details.
		class ConnectRequest < ::Protocol::HTTP::Request
			include ::Protocol::WebSocket::Headers
			
			class Wrapper
				def initialize(stream, response)
					@response = response
					@body = @response.body
					@stream = stream
				end
				
				attr_accessor :response
				
				attr_accessor :body
				attr_accessor :stream
				
				def stream?
					@response.success? and @stream
				end
				
				def status
					@response.status
				end
				
				def headers
					@response.headers
				end
				
				def body?
					true
				end
				
				def protocol
					@response.protocol
				end
			end
			
			class Hijack < Protocol::HTTP::Body::Readable
				def initialize(request)
					@request = request
					@stream = nil
				end
				
				def stream?
					true
				end
				
				attr :stream
				
				def call(stream)
					@stream = stream
				end
			end
			
			def initialize(request, protocols: [], version: 13, &block)
				body = Hijack.new(self)
				
				headers = ::Protocol::HTTP::Headers[request.headers]
				
				headers.add(SEC_WEBSOCKET_VERSION, String(version))
				
				if protocols.any?
					headers.add(SEC_WEBSOCKET_PROTOCOL, protocols.join(','))
				end
				
				super(request.scheme, request.authority, ::Protocol::HTTP::Methods::CONNECT, request.path, nil, headers, body, PROTOCOL)
			end
			
			def call(connection)
				response = super
				
				Wrapper.new(@body.stream, response)
			end
		end
	end
end
