# frozen_string_literals: true
#
# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative '../connection'
require_relative '../response'

module Async
	module WebSocket
		module Adapters
			module HTTP
				include ::Protocol::WebSocket::Headers
				
				def self.websocket?(request)
					Array(request.protocol).any? { |e| e.casecmp?(PROTOCOL) }
				end
				
				def self.open(request, headers: [], protocols: [], extensions: nil, **options, &block)
					if websocket?(request)
						# Select websocket sub-protocol:
						if requested_protocol = request.headers[SEC_WEBSOCKET_PROTOCOL]
							protocol = (requested_protocol & protocols).first
						end
						
						klass = Connection
						
						extensions&.each do |extension|
							# Given the request header which contains the "offer" by the client, configure the klass to suit.
							klass = klass.negotiate(request.headers, klass, options)
						end
						
						if extensions = request.headers[SEC_WEBSOCKET_EXTENSIONS]
							extensions = handler.negotiate(requested_extensions)
						end
						
						response = Response.for(request, headers, protocol: protocol, **options) do |stream|
							# Once we get to this point, we no longer need to hold on to the response:
							response = nil
							
							framer = Protocol::WebSocket::Framer.new(stream)
							connection = klass.call(framer, protocol, extensions)
							
							yield connection
							
							connection.close unless connection.closed?
						end
						
						# Once we get to this point, we no longer need to hold on to the request:
						request = nil
						
						return response
					end
				end
			end
		end
	end
end
