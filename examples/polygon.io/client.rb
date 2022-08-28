#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require 'async'
require 'async/io/stream'
require 'async/http/endpoint'

require 'hexdump'

require_relative '../../lib/async/websocket/client'

Async do |task|
	endpoint = Async::HTTP::Endpoint.parse('wss://socket.polygon.io/stocks', alpn_protocols: Async::HTTP::Protocol::HTTP11.names)
	
	# endpoint = Async::HTTP::Endpoint.parse('wss://socket.polygon.io/stocks')
	
	Async::WebSocket::Client.connect(endpoint) do |connection|
		puts "Connected..."
		while message = connection.read
			puts "> #{message.inspect}"
		end
	ensure
		puts "close"
	end
end
