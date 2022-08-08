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

require_relative 'http'

module Async
	module WebSocket
		module Adapters
			module Rack
				include ::Protocol::WebSocket::Headers
				
				HTTP_SEC_WEBSOCKET_PROTOCOL = 'HTTP_SEC_WEBSOCKET_PROTOCOL'.freeze

				def self.protocols(env)
					if protocols = env['rack.protocol']
						return Array(protocols)
					elsif upgrade = env['HTTP_UPGRADE']
						return upgrade.split(/\s*,\s*/)
					end
				end

				def self.websocket?(env)
					protocols(env).any?{|name| name.casecmp?(PROTOCOL)}
				end

				def self.open(env, protocols: [], handler: Connection, &block)
					if websocket?(env)
						if requested_protocol = env[HTTP_SEC_WEBSOCKET_PROTOCOL]
							protocol = (requested_protocol & protocols).first
						end
						


						if response = HTTP.open(request, **options, &block)
							headers = response.headers
							
							if protocol = response.protocol
								headers = Protocol::HTTP::Headers::Merged.new(headers, [
									['rack.protocol', protocol]
								])
							end
							
							return [response.status, headers.to_h, response.body]
						end
					end
				end


					if websocket?(request)
						# Select websocket sub-protocol:
						if requested_protocol = request.headers[SEC_WEBSOCKET_PROTOCOL]
							protocol = (requested_protocol & protocols).first
						end
						
						response = Response.for(request, headers, protocol: protocol, **options) do |stream|
							# Once we get to this point, we no longer need to hold on to the response:
							response = nil
							
							framer = Protocol::WebSocket::Framer.new(stream)
							connection = handler.call(framer, protocol)
							
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
