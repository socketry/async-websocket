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

require 'rack/test'
require 'falcon/server'
require 'falcon/adapters/rack'
require 'async/http/endpoint'

RSpec.describe Async::WebSocket::Adapters::Rack do
	include_context Async::RSpec::Reactor
	
	let(:endpoint) {Async::HTTP::Endpoint.parse("http://localhost:7050")}
	let(:app) {Rack::Builder.parse_file(File.expand_path('rack/config.ru', __dir__)).first}
	let(:server) {Falcon::Server.new(Falcon::Server.middleware(app), endpoint)}
	let(:client) {Async::HTTP::Client.new(endpoint)}
	
	let!(:server_task) do
		reactor.async do
			server.run
		end
	end
	
	after do
		server_task.stop
	end
	
	it "can make non-websocket connection to server" do
		response = client.get("/")
		
		expect(response).to be_success
		expect(response.read).to be == "Hello World"
		
		client.close
	end
	
	let(:message) do
		{text: "Hello World"}
	end
	
	it "can make websocket connection to server" do
		Async::WebSocket::Client.connect(endpoint) do |connection|
			connection.write(message)
			
			expect(connection.read).to be == message
			
			connection.close
		end
	end
	
	it "should use mask over insecure connection" do
		expect(endpoint).to_not be_secure
		
		Async::WebSocket::Client.connect(endpoint) do |connection|
			expect(connection.mask).to_not be_nil
		end
	end
	
	it "should negotiate protocol" do
		Async::WebSocket::Client.connect(endpoint, protocols: ['ws']) do |connection|
			expect(connection.protocol).to be == 'ws'
		end
	end
end
