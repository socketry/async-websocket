#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2022, by Samuel Williams.

require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'

URL = ARGV.pop || "http://127.0.0.1:7070"

Async do |task|
	endpoint = Async::HTTP::Endpoint.parse(URL)
	
	Async::WebSocket::Client.connect(endpoint) do |connection|
		connection.send_text("Hello World")
		connection.flush
		
		while message = connection.read
			p message
		end
	end
end
