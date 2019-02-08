require "async/websocket/client"

RSpec.describe Async::WebSocket::Client do
	let(:client_double) {
		instance_double(WebSocket::Driver::Client, on: nil, start: nil)
	}

	before do
		allow(WebSocket::Driver).to receive(:client).and_return(client_double)
	end

	it "sets headers on the driver" do
		headers = {
			"Foo" => "Bar",
			"Baz" => "Qux"
		}

		headers.each do |key, value|
			expect(client_double).to receive(:set_header).with(key, value)
		end

		described_class.new(double(write: nil), "", headers)
	end

	context "without passing headers" do
		it "does not fail" do
			expect {
				described_class.new(double(write: nil))
			}.not_to raise_error
		end
	end
end
