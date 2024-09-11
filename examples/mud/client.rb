#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2020, by Juan Antonio Martín Lucas.

require "async"
require "async/http/endpoint"
require "async/websocket/client"

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "http://127.0.0.1:7070"

Async do |task|
	endpoint = Async::HTTP::Endpoint.parse(URL)
	
	Async::WebSocket::Client.connect(endpoint) do |connection|
		task.async do
			$stdout.write "> "
			
			while line = $stdin.gets
				connection.write(Protocol::WebSocket::TextMessage.generate({input: line}))
				connection.flush
				
				$stdout.write "> "
			end
		end
		
		while message = connection.read
			# Rewind to start of line:
			$stdout.write "\r"
			
			# Clear line:
			$stdout.write "\e[2K"
			
			# Print message:
			$stdout.puts message.to_h
			
			$stdout.write "> "
		end
	end
end
