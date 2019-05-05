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

require_relative 'framer'

require 'json'
require 'securerandom'

module Async
	module WebSocket
		# This is a basic synchronous websocket client:
		class Connection < Framer
			def initialize(stream, protocol, mask: SecureRandom.bytes(4), format: JSON)
				super(stream)
				
				@protocol = protocol
				@mask = mask
				@format = format
			end
			
			attr :protocol
			
			def next_message
				self.flush
				
				while frame = self.read_frame
					case frame.opcode
					when Frame::CLOSE
						return nil
					when Frame::TEXT
						return @format.load(frame.payload)
					else
						Async.logger.warn(self) {"Ignoring #{frame}!"}
					end
				end
			end
			
			def send_message(data, opcode = Frame::TEXT)
				payload = @format.dump(data)
				
				frame = Frame.new(true, opcode, @mask, payload)
				
				self.write_frame(frame)
			end
		end
	end
end
