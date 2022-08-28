# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'async/websocket'
require 'async/websocket/client'
require 'async/websocket/adapters/rack'
require 'rack_application'

describe Async::WebSocket::Adapters::Rack do
	include RackApplication
	
	it "can make non-websocket connection to server" do
		response = client.get("/")
		
		expect(response).to be(:success?)
		expect(response.read).to be == "Hello World"
		
		client.close
	end
	
	let(:message) do
		Protocol::WebSocket::JSONMessage.generate({text: "Hello World"})
	end
	
	it "can make websocket connection to server" do
		Async::WebSocket::Client.connect(client_endpoint) do |connection|
			connection.write(message)
			
			expect(connection.read).to be == message
			
			connection.close
		end
	end
	
	it "should use mask over insecure connection" do
		expect(endpoint).not.to be(:secure?)
		
		Async::WebSocket::Client.connect(client_endpoint) do |connection|
			expect(connection.mask).not.to be_nil
		end
	end
	
	it "should negotiate protocol" do
		Async::WebSocket::Client.connect(client_endpoint, protocols: ['ws']) do |connection|
			expect(connection.protocol).to be == 'ws'
		end
	end
end
