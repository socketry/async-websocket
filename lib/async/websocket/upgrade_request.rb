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

require 'protocol/http/middleware'
require 'protocol/http/request'

require 'protocol/http/headers'
require 'protocol/websocket/headers'

require 'securerandom'

require_relative 'error'

module Async
	module WebSocket
		# This is required for HTTP/1.x to upgrade the connection to the WebSocket protocol.
		class UpgradeRequest < ::Protocol::HTTP::Request
			include ::Protocol::WebSocket::Headers
			
			class Wrapper
				def initialize(response)
					@response = response
					@stream = nil
				end
				
				def stream?
					@response.status == 101
				end
				
				def status
					@response.status
				end
				
				def headers
					@response.headers
				end
				
				def body?
					false
				end
				
				def body
					nil
				end
				
				def protocol
					@response.protocol
				end
				
				def stream
					@stream ||= @response.hijack!
				end
			end
			
			def initialize(request, protocols: [], version: 13)
				@key = Nounce.generate_key
				
				headers = [
					[SEC_WEBSOCKET_KEY, @key],
					[SEC_WEBSOCKET_VERSION, version],
				]
				
				if protocols.any?
					headers << [SEC_WEBSOCKET_PROTOCOL, protocols.join(',')]
				end
				
				merged_headers = ::Protocol::HTTP::Headers::Merged.new(request.headers, headers)
				
				super(request.scheme, request.authority, ::Protocol::HTTP::Methods::GET, request.path, nil, merged_headers, nil, PROTOCOL)
			end
			
			def call(connection)
				response = super
				
				if accept_digest = response.headers[SEC_WEBSOCKET_ACCEPT]&.first
					expected_accept_digest = Nounce.accept_digest(@key)
					
					unless accept_digest and accept_digest == expected_accept_digest
						raise ProtocolError, "Invalid accept digest, expected #{expected_accept_digest.inspect}, got #{accept_digest.inspect}!"
					end
				end
				
				return Wrapper.new(response)
			end
		end
	end
end
