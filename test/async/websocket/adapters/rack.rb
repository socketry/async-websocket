# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'async/websocket'
require 'async/websocket/client'
require 'async/websocket/adapters/rack'
require 'rack_application'

describe Async::WebSocket::Adapters::Rack do
	it "can determine whether a rack env is a websocket request" do
		expect(Async::WebSocket::Adapters::Rack.websocket?(Rack::MockRequest.env_for("/"))).to be == false
		expect(Async::WebSocket::Adapters::Rack.websocket?(Rack::MockRequest.env_for("/", 'HTTP_CONNECTION' => 'upgrade', 'HTTP_UPGRADE' => 'websocket'))).to be == true
	end
	
	with 'rack application' do
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
end
