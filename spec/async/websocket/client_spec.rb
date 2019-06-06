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
require "async/websocket/response"

RSpec.describe Async::WebSocket::Client do
	describe '#connect' do
		let(:headers) {[
			["Foo", "Bar"],
			["Baz", "Qux"]
		]}
		
		let(:client) {double}
		let(:stream) {double}
		
		subject {described_class.new(client)}
		let(:response) {Protocol::HTTP::Response.new(nil, 101, {}, nil, Protocol::WebSocket::Headers::PROTOCOL)}
		
		it "sets client request headers" do
			expect(response).to receive(:stream?).and_return(true)
			expect(response).to receive(:stream).and_return(stream)
			
			expect(client).to receive(:call) do |request|
				expect(request.headers.to_h).to include("Foo", "Baz")
			end.and_return(response)
			
			subject.connect("/server", headers: headers)
		end
	end
end
