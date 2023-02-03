# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'protocol/websocket/json_message'
require 'protocol/http/middleware/builder'

require 'async/websocket/client'
require 'async/websocket/server'
require 'async/websocket/adapters/http'

require 'sus/fixtures/async/http/server_context'

ServerExamples = Sus::Shared('a websocket server') do
	it "can establish connection" do
		connection = websocket_client.connect(endpoint.authority, "/server")
		
		connection.send_text("Hello World!")
		message = connection.read
		expect(message.to_str).to be == "Hello World!"
		
		connection.close
	end
	
	it "can establish connection with block" do
		websocket_client.connect(endpoint.authority, "/server") do |connection|
			connection.send_text("Hello World!")
			message = connection.read
			expect(message.to_str).to be == "Hello World!"
		end
	end
	
	it "can open client and establish client with block" do
		Async::WebSocket::Client.open(client_endpoint) do |client|
			client.connect(endpoint.authority, "/server") do |connection|
				connection.send_text("Hello World!")
				message = connection.read
				expect(message.to_str).to be == "Hello World!"
			end
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
	
	with 'server middleware' do
		let(:app) do
			Protocol::HTTP::Middleware.build do
				use Async::WebSocket::Server, protocols: ['echo', 'baz'] do |connection|
					connection.send_text("protocol: #{connection.protocol}")
					connection.close
				end
			end
		end
		
		it "can establish connection with explicit protocol" do
			connection = websocket_client.connect(endpoint.authority, "/server", protocols: ['echo', 'foo', 'bar'])
			
			# The negotiated protocol:
			expect(connection.protocol).to be == 'echo'
			
			begin
				expect(connection.read).to be == "protocol: echo"
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
	
	let(:websocket_client) {Async::WebSocket::Client.open(client_endpoint)}
	
	let(:app) do
		Protocol::HTTP::Middleware.for do |request|
			Async::WebSocket::Adapters::HTTP.open(request) do |connection|
				while message = connection.read
					connection.write(message)
				end
			end or Protocol::HTTP::Response[404, {}, []]
		end
	end
	
	with 'http/1' do
		let(:protocol) {Async::HTTP::Protocol::HTTP1}
		it_behaves_like ServerExamples 
		
		it "fails with bad request if missing nounce" do
			request = Protocol::HTTP::Request["GET", "/", {
				"upgrade" => "websocket",
				"connection" => "upgrade",
			}]
			
			response = client.call(request)
			
			expect(response).to be(:bad_request?)
		end
		
		let(:timeout) {nil}
		
		with 'broken server' do
			let(:app) do
				Protocol::HTTP::Middleware.for do |request|
					response = Async::WebSocket::Adapters::HTTP.open(request) do |connection|
						while message = connection.read
							connection.write(message)
						end
					end
					
					if response
						response.tap do
							response.headers.set('sec-websocket-accept', '2badsheep')
						end
					else
						Protocol::HTTP::Response[404, {}, []]
					end
				end
			end
			
			it "fails with protocol error if nounce doesn't match" do
				expect do
					websocket_client.connect(endpoint.authority, "/server") {}
				end.to raise_exception(Protocol::WebSocket::ProtocolError)
			end
		end
	end
	
	with 'http/2' do
		let(:protocol) {Async::HTTP::Protocol::HTTP2}
		it_behaves_like ServerExamples
	end
end
