

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