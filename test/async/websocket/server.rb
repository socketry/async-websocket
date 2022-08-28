# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'protocol/websocket/json_message'

require 'async/websocket/client'
require 'async/websocket/server'
require 'async/websocket/adapters/http'

require 'sus/fixtures/async/http/server_context'

WebSocketServerExamples = Sus::Shared('a websocket server') do
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	let(:message) {"Hello World"}
	
	let(:app) do
		Protocol::HTTP::Middleware.for do |request|
			Async::WebSocket::Adapters::HTTP.open(request) do |connection|
				connection.send_text(message)
				connection.close
			end or Protocol::HTTP::Response[404, {}, []]
		end
	end
	
	let(:websocket_client) {Async::WebSocket::Client.open(client_endpoint)}
	
	it "can establish connection" do
		connection = websocket_client.connect(endpoint.authority, "/server")
		
		begin
			expect(connection.read).to be == message
			expect(connection.read).to be_nil
			expect(connection).to be(:closed?)
		ensure
			connection.close
		end
	end
	
	with "headers" do
		let(:headers) {{"foo" => "bar"}}
		
		let(:app) do
			Protocol::HTTP::Middleware.for do |request|
				Async::WebSocket::Adapters::HTTP.open(request) do |connection|
					message = Protocol::WebSocket::JSONMessage.generate(request.headers.fields)
					message.send(connection)
					
					connection.close
				end or Protocol::HTTP::Response[404, {}, []]
			end
		end
		
		it "can send headers" do
			connection = websocket_client.connect(endpoint.authority, "/headers", headers: headers)
			
			begin
				json_message = Protocol::WebSocket::JSONMessage.wrap(connection.read)
				
				expect(json_message.to_h).to have_keys(*headers.keys)
				expect(connection.read).to be_nil
				expect(connection).to be(:closed?)
			ensure
				connection.close
			end
		end
	end
end

describe Async::HTTP::Protocol::HTTP1 do
	let(:protocol) {subject}
	
	it_behaves_like WebSocketServerExamples
end

describe Async::HTTP::Protocol::HTTP2 do
	let(:protocol) {subject}
	
	it_behaves_like WebSocketServerExamples
end
