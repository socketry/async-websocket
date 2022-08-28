#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2022, by Samuel Williams.

require 'async'
require 'async/http'
require 'async/websocket'

URL = "wss://stream.binance.com:9443/ws/btcusdt@bookTicker"

Async do |task|
	endpoint = Async::HTTP::Endpoint.parse(URL, alpn_protocols: Async::HTTP::Protocol::HTTP11.names)
	
	Async::WebSocket::Client.connect(endpoint) do |connection|
		while message = connection.read
			p message
		end
	end
end
