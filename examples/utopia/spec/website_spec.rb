# frozen_string_literal: true

require_relative 'website_context'

# Learn about best practice specs from http://betterspecs.org
RSpec.describe "website", timeout: 120 do
	include_context "server"
	
	let(:spider) {Benchmark::HTTP::Spider.new(depth: 128)}
	let(:statistics) {Benchmark::HTTP::Statistics.new}
	
	it "should be responsive" do
		Async::HTTP::Client.open(endpoint, connection_limit: 8) do |client|
			spider.fetch(statistics, client, endpoint.url) do |method, uri, response|
				if response.failure?
					Async.logger.error{"#{method} #{uri} -> #{response.status}"}
				end
			end.wait
		end
		
		statistics.print
		
		expect(statistics.samples).to be_any
		expect(statistics.failed).to be_zero
	end
end
