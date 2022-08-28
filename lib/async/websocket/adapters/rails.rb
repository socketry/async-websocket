# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require_relative 'rack'

module Async
	module WebSocket
		module Adapters
			module Rails
				def self.open(request, **options, &block)
					if response = Rack.open(request.env, **options, &block)
						response[1]['rack.hijack'] = lambda do |stream|
							response[2].call(stream)
						end
						
						# Close the response to prevent Rails from... trying to render a view?
						return ::ActionDispatch::Response.new(response[0], response[1], nil).tap(&:close)
					end
					
					return ::ActionDispatch::Response.new(404, [], [])
				end
			end
		end
	end
end
