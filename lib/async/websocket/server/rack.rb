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
require_relative '../digest'

module Async
	module WebSocket
		module Server
			class Rack
				def self.open(env, **options, &block)
					return nil unless env['rack.hijack?']
					
					connection = self.new(env, **options)
					
					if connection.supported?
						return connection.response(&block)
					else
						return nil
					end
				end
				
				def initialize(env, **options)
					scheme = env['rack.url_scheme'] == 'https' ? 'wss' : 'ws'
					@url = "#{scheme}://#{env['HTTP_HOST']}#{env['REQUEST_URI']}"
					
					@key = env['HTTP_SEC_WEBSOCKET_KEY']
					@version = Integer(env['HTTP_SEC_WEBSOCKET_VERSION'])
				end
				
				def supported?
					@key and @version >= 13
				end
				
				def handle(stream, &block)
					yield Connection.new(stream)
				end
				
				def response(headers = [], &block)
					[101, [
						['connection', 'upgrade'],
						['upgrade', 'websocket'],
						['sec-websocket-accept', WebSocket.accept_digest(@key)],
						['rack.hijack', ->(stream){self.handle(stream, &block)}]
					] + headers, nil]
				end
			end
		end
	end
end
