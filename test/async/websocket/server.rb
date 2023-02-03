# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'protocol/websocket/json_message'
require 'protocol/http/middleware/builder'

require 'async/websocket/client'
require 'async/websocket/server'
require 'async/websocket/adapters/http'

require 'sus/fixtures/async/http/server_context'

ServerExamples = Sus::Shared('a websocket server') do
	let(:websocket_client) {Async::WebSocket::Client.open(client_endpoint)}
	
	with 'generic application' do
		let(:message) {"Hello World"}
		
		let(:app) do
			Protocol::HTTP::Middleware.for do |request|
				Async::WebSocket::Adapters::HTTP.open(request) do |connection|
					connection.send_text(message)
					connection.close
				end or Protocol::HTTP::Response[404, {}, []]
			end
		end
		
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
	
	with 'server middleware' do
		let(:app) do
			Protocol::HTTP::Middleware.build do
				use Async::WebSocket::Server do |connection|
					connection.send_text("Hello World")
					connection.close
				end
			end
		end
		
		it "can establish connection" do
			connection = websocket_client.connect(endpoint.authority, "/server")
			
			begin
				expect(connection.read).to be == "Hello World"
				expect(connection.read).to be_nil
				expect(connection).to be(:closed?)
			ensure
				connection.close
			end
		end
	end
end

describe Async::WebSocket::Server do
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	with 'http/1' do
		let(:protocol) {Async::HTTP::Protocol::HTTP1}
		it_behaves_like ServerExamples
	end
	
	with 'http/2' do
		let(:protocol) {Async::HTTP::Protocol::HTTP2}
		it_behaves_like ServerExamples
	end
end
