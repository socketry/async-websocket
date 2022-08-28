# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

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
			
			def call
				self.close
			end
		end
	end
end
