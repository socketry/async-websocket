# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2023, by Samuel Williams.
# Copyright, 2019, by destructobeam.

require 'async/websocket/connection'

describe Async::WebSocket::Connection do
	let(:framer) {Protocol::WebSocket::Framer.new(nil)}
	let(:connection) {subject.new(framer)}
	
	it "is not reusable" do
		expect(connection).not.to be(:reusable?)
	end
	
	it "should use mask if specified" do
		mock(framer) do |mock|
			mock.replace(:write_frame) do |frame|
				expect(frame.mask).to be == connection.mask
			end
		end
		
		connection.send_text("Hello World")
	end
end
