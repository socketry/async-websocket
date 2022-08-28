# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative 'connection'
require_relative 'response'

require 'protocol/http/middleware'

module Async
	module WebSocket
		class Server < ::Protocol::HTTP::Middleware
			include ::Protocol::WebSocket::Headers
			
			def initialize(delegate, protocols: [], handler: Connection)
				super(delegate)
				
				@protocols = protocols
				@handler = handler
			end
			
			def select_protocol(request)
				if requested_protocol = request.headers[SEC_WEBSOCKET_PROTOCOL]
					return (requested_protocol & @protocols).first
				end
			end
			
			def response(request)
			end
			
			def call(request)
				if request.protocol == PROTOCOL
					# Select websocket sub-protocol:
					protocol = select_protocol(request)
					
					# request.headers = nil
					
					Response.for(request, headers, protocol: protocol, **options) do |stream|
						framer = Protocol::WebSocket::Framer.new(stream)
						
						yield handler.call(framer, protocol)
					end
				else
					super
				end
			end
		end
	end
end
