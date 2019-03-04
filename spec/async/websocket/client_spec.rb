# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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

		described_class.new(double(write: nil), "", headers: headers)
	end

	context "without passing headers" do
		it "does not fail" do
			expect {
				described_class.new(double(write: nil))
			}.not_to raise_error
		end
	end
end
