#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require "async"
require "async/http/endpoint"
require_relative "../../lib/async/websocket/client"

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "https://localhost:8080"
ENDPOINT = Async::HTTP::Endpoint.parse(URL)

Async do |task|
	Async::WebSocket::Client.connect(ENDPOINT) do |connection|
		input_task = task.async do
			while line = $stdin.gets
				message = Protocol::WebSocket::TextMessage.generate({text: line})
				message.send(connection)
				connection.flush
			end
		end
		
		puts "Connected..."
		while message = connection.read
			puts "> #{message.to_h}"
		end
	ensure
		input_task&.stop
	end
end
