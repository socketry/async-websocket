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

require_relative 'connection'
require_relative 'response'

require 'protocol/http/middleware'

module Async
	module WebSocket
		class Server < ::Protocol::HTTP::Middleware
			include ::Protocol::WebSocket::Headers
			
			def initialize(delegate, protocols: [], handler: Connection)
				super(delegate)
				
				@protocols = protocols
				@handler = handler
			end
			
			def select_protocol(request)
				if requested_protocol = request.headers[SEC_WEBSOCKET_PROTOCOL]
					return (requested_protocol & @protocols).first
				end
			end
			
			def response(request)
			end
			
			def call(request)
				if request.protocol == PROTOCOL
					# Select websocket sub-protocol:
					protocol = select_protocol(request)
					
					Response.for(request, headers, protocol: protocol, **options) do |stream|
						framer = Protocol::WebSocket::Framer.new(stream)
						
						yield handler.call(framer, protocol)
					end
				else
					super
				end
			end
		end
	end
end
