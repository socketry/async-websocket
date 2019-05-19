
require_relative 'website_context'

require 'falcon/server'
require 'falcon/adapters/rack'

require 'async/http/endpoint'
require 'async/websocket/client'

# Learn about best practice specs from http://betterspecs.org
RSpec.describe "my website" do
	include_context "website"
	
	it "should have an accessible front page" do
		get "/"
		
		follow_redirect!
		
		expect(last_response.status).to be == 200
	end
	
	context "websockets" do
		include_context Async::RSpec::Reactor
		
		let(:endpoint) {Async::HTTP::Endpoint.parse("http://localhost:9282")}
		let(:server) {Falcon::Server.new(Falcon::Adapters::Rack.new(app), endpoint)}
		
		let(:hello_message) do
			{
				user: "test",
				text: "Hello World",
			}
		end
		
		let!(:server_task) do
			server_task = reactor.async do
				server.run
			end
		end
		
		after(:each) do
			server_task.stop
		end
		
		it "can connect to server" do
			endpoint.connect do |socket|
				connection = Async::WebSocket::Client.new(socket, "ws://localhost/server/connect")
				
				connection.write(hello_message)
				
				message = connection.read
				expect(message).to be == hello_message
			end
		end
	end
end
