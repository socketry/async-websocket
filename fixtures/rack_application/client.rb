#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "http://localhost:7070"

Async do |task|
	endpoint = Async::HTTP::Endpoint.parse(URL)
	headers = {'token' => 'wubalubadubdub'}
	
	Async::WebSocket::Client.open(endpoint, headers: headers) do |connection|
		input_task = task.async do
			while line = $stdin.gets
				connection.write({user: USER, text: line})
				connection.flush
			end
		end
		
		connection.write({
			user: USER,
			status: "connected",
		})
		
		while message = connection.read
			puts message.inspect
		end
	ensure
		input_task&.stop
	end
end
