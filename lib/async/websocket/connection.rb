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

require 'protocol/websocket/connection'
require 'protocol/websocket/headers'

require 'json'

module Async
	module WebSocket
		Frame = ::Protocol::WebSocket::Frame
		
		# This is a basic synchronous websocket client:
		class Connection < ::Protocol::WebSocket::Connection
			include ::Protocol::WebSocket::Headers
			
			def self.call(framer, protocol = [], extensions = nil, **options)
				instance = self.new(framer, Array(protocol).first, **options)
				
				extensions&.apply(instance)
				
				return instance unless block_given?
				
				begin
					yield instance
				ensure
					instance.close
				end
			end
			
			def initialize(framer, protocol = nil, response: nil, **options)
				super(framer, **options)
				
				@protocol = protocol
				@response = response
			end
			
			def reusable?
				false
			end
			
			def close
				super
				
				if @response
					@response.finish
					@response = nil
				end
			end
			
			attr :protocol
			
			def read
				if buffer = super
					parse(buffer)
				end
			end
			
			def write(object)
				super(dump(object))
			end
			
			def parse(buffer)
				JSON.parse(buffer, symbolize_names: true)
			end
			
			def dump(object)
				JSON.dump(object)
			end
			
			def call
				self.close
			end
		end
	end
end
