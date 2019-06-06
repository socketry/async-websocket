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
			module Rack
				include ::Protocol::WebSocket::Headers
				
				def self.websocket?(env)
					request = env['async.http.request'] and Array(request.protocol).include?(PROTOCOL)
				end
				
				def self.open(env, headers: [], protocols: [], handler: Connection, **options, &block)
					if request = env['async.http.request'] and Array(request.protocol).include?(PROTOCOL)
						# Select websocket sub-protocol:
						if requested_protocol = request.headers[SEC_WEBSOCKET_PROTOCOL]
							protocol = (requested_protocol & protocols).first
						end
						
						response = Response.for(request, headers, protocol: protocol, **options) do |stream|
							framer = Protocol::WebSocket::Framer.new(stream)
							
							connection = handler.call(framer, protocol)
							yield connection
							
							connection.close unless connection.closed?
						end
						
						headers = response.headers
						
						if protocol = response.protocol
							headers = Protocol::HTTP::Headers::Merged.new(headers, [
								['rack.protocol', protocol]
							])
						end
						
						return [response.status, headers, response.body]
					end
				end
			end
		end
	end
end
