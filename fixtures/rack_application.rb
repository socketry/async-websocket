# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'sus/fixtures/async/http/server_context'
require 'protocol/rack/adapter'

module RackApplication
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	def builder
		Rack::Builder.parse_file(File.expand_path('rack_application/config.ru', __dir__))
	end
	
	def app
		Protocol::Rack::Adapter.new(builder)
	end
end
