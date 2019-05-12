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

require 'protocol/http1/connection'
require 'protocol/websocket/digest'

require 'securerandom'

require_relative 'connection'
require_relative 'error'

module Async
	module WebSocket
		# This is a basic synchronous websocket client:
		class Client
			def self.open(endpoint, **options, &block)
				# endpoint = Async::HTTP::URLEndpoint.parse(url)
				client = self.new(endpoint, **options)
				
				return client unless block_given?
				
				client.get(endpoint.path, &block)
			end
			
			# @option protocols [Array] a list of supported sub-protocols to negotiate with the server.
			def initialize(endpoint, headers: [], protocols: [], version: 13, key: SecureRandom.base64(16))
				@endpoint = endpoint
				@version = version
				@headers = headers
				
				@protocols = protocols
				
				@key = key
			end
			
			def mask
				# Mask is only required on insecure connections, because of bad proxy implementations.
				unless @endpoint.secure?
					SecureRandom.bytes(4)
				end
			end
			
			attr :headers
			
			def connect
				peer = @endpoint.connect
				
				return ::Protocol::HTTP1::Connection.new(IO::Stream.new(peer), false)
			end
			
			def request_headers
				headers = [
					['sec-websocket-key', @key],
					['sec-websocket-version', @version]
				] + @headers.to_a
				
				if @protocols.any?
					headers << ['sec-websocket-protocol', @protocols.join(',')]
				end
				
				return headers
			end
			
			def get(path = '/', &block)
				self.call('GET', path, &block)
			end
			
			HTTP_VERSION = 'HTTP/1.0'.freeze
			
			def make_connection(stream, headers)
				protocol = headers['sec-websocket-protocol']&.first
				
				framer = Protocol::WebSocket::Framer.new(stream)
				
				return Connection.new(framer, protocol, mask: self.mask)
			end
			
			def call(method, path)
				client = connect
				client.upgrade!("websocket")
				
				client.write_request(@endpoint.authority, method, @endpoint.path, HTTP_VERSION, self.request_headers)
				stream = client.write_upgrade_body
				
				version, status, reason, headers, body = client.read_response(method)
				
				raise ProtocolError, "Expected status 101, got #{status}!" unless status == 101
				
				accept_digest = headers['sec-websocket-accept'].first
				if accept_digest.nil? or accept_digest != ::Protocol::WebSocket.accept_digest(@key)
					raise ProtocolError, "Invalid accept header, got #{accept_digest.inspect}!"
				end
				
				connection = make_connection(stream, headers)
					
				return connection unless block_given?
				
				begin
					yield connection
				ensure
					connection.close
				end
			end
		end
	end
end
