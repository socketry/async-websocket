# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.
# Copyright, 2023, by Thomas Morgan.

require "async/websocket/client"
require "async/websocket/adapters/http"

require "sus/fixtures/async/http/server_context"

ClientExamples = Sus::Shared("a websocket client") do
	let(:app) do
		Protocol::HTTP::Middleware.for do |request|
			Async::WebSocket::Adapters::HTTP.open(request) do |connection|
				while message = connection.read
					connection.write(message)
				end
				
				connection.shutdown
			rescue Protocol::WebSocket::ClosedError
				# Ignore this error.
			ensure
				connection.close
			end or Protocol::HTTP::Response[404, {}, []]
		end
	end
	
	with "#send_close" do
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
	
	with "#close" do
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

		it "closes with custom error" do
			connection = Async::WebSocket::Client.connect(client_endpoint)
			message = connection.read
			
			expect do
				connection.read
			end.to raise_exception(Protocol::WebSocket::Error).and(have_attributes(code: be == 1001))
		end
	end
	
	with "#connect" do
		let(:app) do
			Protocol::HTTP::Middleware.for do |request|
				Async::WebSocket::Adapters::HTTP.open(request) do |connection|
					connection.send_text("authority: #{request.authority}")
					connection.send_text("path: #{request.path}")
					connection.send_text("protocol: #{Array(request.protocol).inspect}")
					connection.send_text("scheme: #{request.scheme}")
					connection.close
				end or Protocol::HTTP::Response[404, {}, []]
			end
		end
		
		it "fully populates the request" do
			connection = Async::WebSocket::Client.connect(client_endpoint)
			expect(connection.read.to_str).to be =~ /authority: localhost:\d+/
			expect(connection.read.to_str).to be == "path: /"
			expect(connection.read.to_str).to be == 'protocol: ["websocket"]'
			expect(connection.read.to_str).to be == "scheme: http"
		ensure
			connection&.close
		end
	end
	
	with "missing support for websockets" do
		let(:app) do
			Protocol::HTTP::Middleware.for do |request|
				Protocol::HTTP::Response[404, {}, []]
			end
		end
		
		it "raises an error when the server doesn't support websockets" do
			expect do
				Async::WebSocket::Client.connect(client_endpoint) {}
			end.to raise_exception(Async::WebSocket::ConnectionError, message: be =~ /Failed to negotiate connection/)
		end
	end
	
	with "deliberate failure response" do
		let(:app) do
			Protocol::HTTP::Middleware.for do |request|
				Protocol::HTTP::Response[401, {}, ["You are not allowed!"]]
			end
		end
		
		it "raises a connection error when the server responds with an error" do
			begin
				Async::WebSocket::Client.connect(client_endpoint) {}
			rescue Async::WebSocket::ConnectionError => error
				expect(error.response.status).to be == 401
				expect(error.response.read).to be == "You are not allowed!"
			end
		end
	end
end

FailedToNegotiate = Sus::Shared("a failed websocket request") do
	it "raises an error" do
		expect do
			Async::WebSocket::Client.connect(client_endpoint) {}
		end.to raise_exception(Async::WebSocket::ConnectionError, message: be =~ /Failed to negotiate connection/)
	end
end

describe Async::WebSocket::Client do
	include Sus::Fixtures::Async::HTTP::ServerContext

	with "http/1" do
		let(:protocol) {Async::HTTP::Protocol::HTTP1}
		it_behaves_like ClientExamples
		
		def valid_headers(request)
			{
				"connection" => "upgrade",
				"upgrade" => "websocket",
				"sec-websocket-accept" => Protocol::WebSocket::Headers::Nounce.accept_digest(request.headers["sec-websocket-key"].first)
			}
		end
		
		with "invalid connection header" do
			let(:app) do
				Protocol::HTTP::Middleware.for do |request|
					Protocol::HTTP::Response[101, valid_headers(request).except("connection"), []]
				end
			end
			
			it_behaves_like FailedToNegotiate
		end
		
		with "invalid upgrade header" do
			let(:app) do
				Protocol::HTTP::Middleware.for do |request|
					Protocol::HTTP::Response[101, valid_headers(request).except("upgrade"), []]
				end
			end
			
			it_behaves_like FailedToNegotiate
		end
		
		with "invalid sec-websocket-accept header" do
			let(:app) do
				Protocol::HTTP::Middleware.for do |request|
					Protocol::HTTP::Response[101, valid_headers(request).merge("sec-websocket-accept"=>"wrong-digest"), []]
				end
			end
			
			it "raises an error" do
				expect do
					Async::WebSocket::Client.connect(client_endpoint) {}
				end.to raise_exception(Async::WebSocket::ProtocolError, message: be =~ /Invalid accept digest/)
			end
		end
		
		with "missing sec-websocket-accept header" do
			let(:app) do
				Protocol::HTTP::Middleware.for do |request|
					Protocol::HTTP::Response[101, valid_headers(request).except("sec-websocket-accept"), []]
				end
			end
			
			it_behaves_like FailedToNegotiate
		end
		
		with "invalid status" do
			let(:app) do
				Protocol::HTTP::Middleware.for do |request|
					Protocol::HTTP::Response[403, valid_headers(request), []]
				end
			end
			
			it_behaves_like FailedToNegotiate
		end
	end
	
	with "http/2" do
		let(:protocol) {Async::HTTP::Protocol::HTTP2}
		it_behaves_like ClientExamples
		
		with "invalid status" do
			let(:app) do
				Protocol::HTTP::Middleware.for do |request|
					Protocol::HTTP::Response[403, {}, []]
				end
			end
			
			it_behaves_like FailedToNegotiate
		end
	end
end
