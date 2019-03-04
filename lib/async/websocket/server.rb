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

module Async
	module WebSocket
		class Server < Connection
			def initialize(env, socket, **options)
				scheme = env['rack.url_scheme'] == 'https' ? 'wss' : 'ws'
				
				@url = "#{scheme}://#{env['HTTP_HOST']}#{env['REQUEST_URI']}"
				@env = env
				
				super(socket, ::WebSocket::Driver.rack(self, options))
			end
			
			attr :env
			attr :url
			
			HIJACK_RESPONSE = [-1, {}, []].freeze
			
			def self.open(env, **options)
				if ::WebSocket::Driver.websocket?(env)
					return nil unless env['rack.hijack?']
					
					# https://github.com/rack/rack/blob/master/SPEC#L89-L93
					peer = Async::IO.try_convert(
						env['rack.hijack'].call
					)
					
					connection = self.new(env, peer, options)
					
					return connection unless block_given?
					
					begin
						yield(connection)
						
						return HIJACK_RESPONSE
					ensure
						connection.close
						peer.close
					end
				end
			end
		end
	end
end
