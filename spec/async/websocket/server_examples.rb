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

require 'async/websocket/client'
require 'async/websocket/server'

require 'async/http/client'
require 'async/http/server'
require 'async/http/endpoint'

RSpec.shared_context Async::WebSocket::Server do
	include_context Async::RSpec::Reactor
	
	let(:protocol) {described_class}
	let(:endpoint) {Async::HTTP::Endpoint.parse('http://127.0.0.1:8008')}
	
	let!(:client) {Async::WebSocket::Client.open(endpoint, protocol)}
	
	let!(:server_task) do
		reactor.async do
			server.run
		end
	end
	
	after(:each) do
		Async.logger.debug(client, "Closing client...")
		client.close
		Async.logger.debug(server_task, "Closing server...")
		server_task.stop
	end
	
	let(:handler) {Async::WebSocket::Connection}
	let(:headers) {Array.new}
	
	let(:message) {["Hello World"]}
	
	let(:server) do
		Async::HTTP::Server.for(endpoint, protocol) do |request|
			if Async::WebSocket::Request.websocket?(request)
				Async::WebSocket::Response.for(request, headers) do |stream|
					framer = Protocol::WebSocket::Framer.new(stream)
					
					connection = handler.call(framer)
					
					connection.write(message)
					
					connection.close
				end
			else
				Protocol::HTTP::Response[404, {}, []]
			end
		end
	end
	
	it "can establish connection" do
		connection = client.connect("/server")
		
		expect(connection.read).to be == message
		expect(connection.read).to be_nil
		expect(connection).to be_closed
		
		connection.close
	end
end