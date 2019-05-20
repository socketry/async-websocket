# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'connect_request'
require_relative 'upgrade_request'

module Async
	module WebSocket
		class Request
			include ::Protocol::WebSocket::Headers
			
			def self.websocket?(request)
				Array(request.protocol).include?(PROTOCOL)
			end
			
			def initialize(scheme = nil, authority = nil, path = nil, headers = [], **options)
				@scheme = scheme
				@authority = authority
				@path = path
				@headers = headers
				
				@options = options
				
				@body = nil
			end
			
			attr_accessor :scheme
			attr_accessor :authority
			attr_accessor :path
			attr_accessor :headers
			
			attr_accessor :body
			
			# Send the request to the given connection.
			def call(connection)
				if connection.http1?
					return UpgradeRequest.new(self, **@options).call(connection)
				elsif connection.http2?
					return ConnectRequest.new(self, **@options).call(connection)
				end
				
				raise HTTP::Error, "Unsupported HTTP version: #{connection.version}!"
			end
			
			def idempotent?
				true
			end
			
			def to_s
				"\#<#{self.class} #{@scheme}://#{@authority}: #{@path}>"
			end
		end
	end
end
