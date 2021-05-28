# Getting Started

This guide shows you how to implement a basic client and server.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add async-websocket
~~~

## Overview Video

<content:youtube-video id="aHop4Yyjs_o" />

## Client Implementation

~~~ ruby
#!/usr/bin/env ruby

require 'async'
require 'async/io/stream'
require 'async/http/endpoint'
require 'async/websocket/client'

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "http://localhost:7070"

Async do |task|
	stdin = Async::IO::Stream.new(
		Async::IO::Generic.new($stdin)
	)
	
	endpoint = Async::HTTP::Endpoint.parse(URL)
	
	Async::WebSocket::Client.connect(endpoint) do |connection|
		input_task = task.async do
			while line = stdin.read_until("\n")
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
~~~

### Force HTTP/1 Connection

This forces the endpoint to connect using `HTTP/1.1`.

~~~ ruby
endpoint = Async::HTTP::Endpoint.parse("https://remote-server.com", alpn_protocols: Async::HTTP::Protocol::HTTP11.names)

Async::WebSocket::Client.connect(endpoint) do ...
~~~

You may want to use this if the server advertises `HTTP/2` but doesn't support `HTTP/2` for WebSocket connections.

## Server Side with Rack & Falcon

~~~ ruby
#!/usr/bin/env -S falcon serve --bind http://localhost:7070 --count 1 -c

require 'async/websocket/adapters/rack'
require 'set'

$connections = Set.new

run lambda {|env|
	Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
		$connections << connection
		
		while message = connection.read
			$connections.each do |connection|
				connection.write(message)
				connection.flush
			end
		end
	ensure
		$connections.delete(connection)
	end or [200, {}, ["Hello World"]]
}
~~~
