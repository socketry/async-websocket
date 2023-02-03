# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'async/websocket/request'

describe Async::WebSocket::Request do
	let(:request) {subject.new("https", "localhost", "/")}
	let(:connection) {Async::WebSocket::Connection.new(nil)}
	
	it "can detect websocket requests" do
		expect(subject).to be(:websocket?, request)
	end
	
	it "should be idempotent" do
		expect(request).to be(:idempotent?)
	end
	
	it "fails if the version is not supported" do
		expect(connection).to receive(:http1?).and_return(false)
		expect(connection).to receive(:http2?).and_return(false)
		expect(connection).to receive(:version).and_return("frob/2.0")
		
		expect do
			request.call(connection)
		end.to raise_exception(Async::WebSocket::UnsupportedVersionError, message: be =~ /Unsupported HTTP version/)
	end
	
	with '#to_s' do
		it "should generate string representation" do
			expect(request.to_s).to be =~ %r{https://localhost/}
		end
	end
end
