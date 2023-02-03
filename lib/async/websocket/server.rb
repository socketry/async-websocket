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
			
			def initialize(delegate, **options, &block)
				super(delegate)
				
				@options = options
				@block = block
			end
			
			def call(request)
				Async::WebSocket::Adapters::HTTP.open(request, **@options, &@block) or super
			end
		end
	end
end
