# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'async/websocket/response'

describe Async::WebSocket::Response do
	it "fails if the version is not recognized" do
		request = Protocol::HTTP::Request.new(nil, nil, "GET", "/", "frob/2.0")
		
		expect do
			subject.for(request)
		end.to raise_exception(Async::WebSocket::UnsupportedVersionError, message: be =~ /Unsupported HTTP version/)
	end
end
