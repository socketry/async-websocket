# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'async/websocket/connection'

describe Async::WebSocket::Connection do
	let(:framer) {Protocol::WebSocket::Framer.new(nil)}
	let(:connection) {subject.new(framer)}
	
	it "should use mask if specified" do
		mock(framer) do |mock|
			mock.replace(:write_frame) do |frame|
				expect(frame.mask).to be == connection.mask
			end
		end
		
		connection.send_text("Hello World")
	end
end
