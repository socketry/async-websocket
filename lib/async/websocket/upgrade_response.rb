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

require 'async/http/body/hijack'
require 'protocol/http/response'
require 'protocol/websocket/headers'

module Async
	module WebSocket
		# The response from the server back to the client for negotiating HTTP/1.x WebSockets.
		class UpgradeResponse < ::Protocol::HTTP::Response
			include ::Protocol::WebSocket::Headers
			
			def initialize(request, headers = nil, protocol: nil, &block)
				headers = Protocol::HTTP::Headers::Merged.new(headers)
				
				if accept_nounce = request.headers[SEC_WEBSOCKET_KEY]&.first
					headers << [[SEC_WEBSOCKET_ACCEPT, Nounce.accept_digest(accept_nounce)]]
					status = 101
				else
					status = 400
				end
				
				if protocol
					headers << [[SEC_WEBSOCKET_PROTOCOL, protocol]]
				end
				
				body = Async::HTTP::Body::Hijack.wrap(request, &block)
				super(request.version, status, headers, body, PROTOCOL)
			end
		end
	end
end
