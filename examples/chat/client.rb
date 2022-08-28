#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'async'
require 'async/io/stream'
require 'async/http/endpoint'
require_relative '../../lib/async/websocket/client'

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "https://localhost:8080"
ENDPOINT = Async::HTTP::Endpoint.parse(URL)

Async do |task|
	stdin = Async::IO::Stream.new(
		Async::IO::Generic.new($stdin)
	)
	
	Async::WebSocket::Client.connect(ENDPOINT) do |connection|
		input_task = task.async do
			while line = stdin.read_until("\n")
				connection.write({text: line})
				connection.flush
			end
		end
		
		puts "Connected..."
		while message = connection.read
			puts "> #{message.inspect}"
		end
	ensure
		input_task&.stop
	end
end
