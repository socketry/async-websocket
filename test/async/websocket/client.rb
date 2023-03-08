# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'async/websocket/client'

require 'sus/fixtures/async/http/server_context'

ClientExamples = Sus::Shared("a websocket client") do
	let(:app) do
		Protocol::HTTP::Middleware.for do |request|
			Async::WebSocket::Adapters::HTTP.open(request) do |connection|
				while message = connection.read
					connection.write(message)
				end
				
				connection.close
			end or Protocol::HTTP::Response[404, {}, []]
		end
	end
	
	with '#send_close' do
		it "can read incoming messages and then close" do
			connection = Async::WebSocket::Client.connect(client_endpoint)
			3.times do
				connection.send_text("Hello World!")
			end
			
			# This informs the server we are done echoing messages:
			connection.send_close
			
			# Collect all the echoed messages:
			messages = []
			while message = connection.read
				messages << message
			end
			
			expect(messages.size).to be == 3
			expect(connection).to be(:closed?)
		ensure
			connection&.close
		end
	end
	
	with '#close' do
		it "can connect to a websocket server and close underlying client" do
			Async do |task|
				connection = Async::WebSocket::Client.connect(client_endpoint)
				connection.send_text("Hello World!")
				message = connection.read
				expect(message.to_str).to be == "Hello World!"
				
				connection.close
				expect(task.children).to be(:empty?)
			end.wait
		end
		
		it "can connect to a websocket server and close underlying client with an error code" do
			Async do |task|
				connection = Async::WebSocket::Client.connect(client_endpoint)
				connection.send_text("Hello World!")
				message = connection.read
				expect(message.to_str).to be == "Hello World!"
				
				connection.close(Protocol::WebSocket::Error::GOING_AWAY, "Bye!")
				expect(task.children).to be(:empty?)
			end.wait
		end
	end
	
	with "#close(1001)" do
		let(:app) do
			Protocol::HTTP::Middleware.for do |request|
				Async::WebSocket::Adapters::HTTP.open(request) do |connection|
					connection.send_text("Hello World!")
					connection.close(1001)
				end
			end
		end

		it 'closes with custom error' do
			connection = Async::WebSocket::Client.connect(client_endpoint)
			message = connection.read
			
			expect do
				connection.read
			end.to raise_exception(Protocol::WebSocket::Error).and(have_attributes(code: be == 1001))
		end
	end
	
	with 'missing support for websockets' do
		let(:app) do
			Protocol::HTTP::Middleware.for do |request|
				Protocol::HTTP::Response[404, {}, []]
			end
		end
		
		it "raises an error when the server doesn't support websockets" do
			expect do
				Async::WebSocket::Client.connect(client_endpoint) {}
			end.to raise_exception(Async::WebSocket::ProtocolError, message: be =~ /Failed to negotiate connection/)
		end
	end
end

describe Async::WebSocket::Client do
	include Sus::Fixtures::Async::HTTP::ServerContext

	with 'http/1' do
		let(:protocol) {Async::HTTP::Protocol::HTTP1}
		it_behaves_like ClientExamples
	end
	
	with 'http/2' do
		let(:protocol) {Async::HTTP::Protocol::HTTP2}
		it_behaves_like ClientExamples
	end
end
