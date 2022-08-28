# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require_relative 'connect_request'
require_relative 'upgrade_request'

module Async
	module WebSocket
		class Request
			include ::Protocol::WebSocket::Headers
			
			def self.websocket?(request)
				Array(request.protocol).include?(PROTOCOL)
			end
			
			def initialize(scheme = nil, authority = nil, path = nil, headers = nil, **options, &block)
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
