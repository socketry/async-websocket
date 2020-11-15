# frozen_string_literal: true

require 'rack/test'
require 'async/rspec/reactor'

RSpec.shared_context "website" do
	include Rack::Test::Methods
	
	let(:rackup_path) {File.expand_path('../config.ru', __dir__)}
	let(:rackup_directory) {File.dirname(rackup_path)}
	
	let(:app) {Rack::Builder.parse_file(rackup_path).first}
end

RSpec.shared_examples_for "valid page" do |path|
	it "can access #{path}" do
		get path
		
		while last_response.redirect?
			follow_redirect!
		end
		
		expect(last_response.status).to be == 200
	end
end

RSpec.shared_context "server" do
	include_context "website"
	include_context Async::RSpec::Reactor
	
	before(:all) do
		require 'falcon/server'
		require 'async/io/unix_endpoint'
		require 'benchmark/http/spider'
	end
	
	let(:endpoint) {Async::HTTP::Endpoint.parse("http://localhost", Async::IO::Endpoint.unix("server.ipc"))}
	
	let!(:server_task) do
		reactor.async do
			middleware = Falcon::Server.middleware(app)
			
			server = Falcon::Server.new(middleware, endpoint)
			
			server.run
		end
	end
	
	after do
		server_task.stop
	end
end
