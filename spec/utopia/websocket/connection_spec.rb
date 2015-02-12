# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'utopia/websocket'
require 'utopia/websocket/client'

require 'rack/test'
require 'puma'

module Utopia::WebSocket::ConnectionSpec
	describe Utopia::WebSocket::Connection do
		include Rack::Test::Methods
		
		before(:all) do
			@app = Rack::Builder.parse_file(File.expand_path('../connection_spec.ru', __FILE__)).first
			
			@server = Puma::Server.new(@app)
			
			@server.add_tcp_listener('localhost', 8085)
			
			@server.run
			
			trap(:SIGINT) do
				@server.stop if @server
				exit
			end
		end
		
		after(:all) do
			@server.stop
			@server = nil
		end
		
		it "should connect to the websocket server" do
			client = Utopia::WebSocket::Client.new("ws://localhost:8085/list", TCPSocket.new('localhost', 8085))
			
			events = []
			
			client.driver.on(:message) do |event|
				events << event
			end
			
			client.read
			
			expect(events.size).to be > 0
		end
	end
end
