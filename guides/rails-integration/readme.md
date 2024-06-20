# Rails Integration

This guide explains how to use `async-websocket` with `falcon`.

## Project Setup

Firstly, we will create a new project for the purpose of this guide:

~~~ bash
$ rails new websockets
--- snip ---
~~~

Then, we need to add the `Async::WebSocket` gem:

~~~ bash
$ bundle add async-websocket
~~~

## Adding the WebSocket Controller

Firstly, generate the controller with a single method:

~~~ bash
$ rails generate controller home index
~~~

Then edit your controller implementation:

~~~ ruby
require 'async/websocket/adapters/rails'

class HomeController < ApplicationController
	# WebSocket clients may not send CSRF tokens, so we need to disable this check.
	skip_before_action :verify_authenticity_token, only: [:index]
	
	def index
		self.response = Async::WebSocket::Adapters::Rails.open(request) do |connection|
			message = Protocol::WebSocket::TextMessage.generate({message: "Hello World"})
			connection.write(message)
		end
	end
end
~~~

### Testing

You can quickly test that the above controller is working. First, start the Rails server:

~~~ bash
$ rails s
=> Booting Puma
=> Rails 7.2.0.beta2 application starting in development 
=> Run `bin/rails server --help` for more startup options
~~~

Then you can connect to the server using a WebSocket client:

~~~ bash
$ websocat ws://localhost:3000/home/index
{"message":"Hello World"}
~~~

### Using Falcon

The default Rails server (Puma) is not suitable for handling a large number of connected WebSocket clients, as it has a limited number of threads (typically between 8 and 16). Each WebSocket connection will require a thread, so the server will quickly run out of threads and be unable to accept new connections. To solve this problem, we can use [Falcon](https://github.com/socketry/falcon) instead, which uses a fiber-per-request architecture and can handle a large number of connections.

We need to remove Puma and add Falcon::

~~~ bash
$ bundle remove puma
$ bundle add falcon
~~~

Now when you start the server you should see something like this:

~~~ bash
$ rails s
=> Booting Falcon v0.47.7
=> Rails 7.2.0.beta2 application starting in development http://localhost:3000
=> Run `bin/rails server --help` for more startup options
~~~


### Using HTTP/2

Falcon supports HTTP/2, which can be used to improve the performance of WebSocket connections. HTTP/1.1 requires a separate TCP connection for each WebSocket connection, while HTTP/2 can handle multiple requessts and WebSocket connections over a single TCP connection. To use HTTP/2, you'd typically use `https`, which allows the client browser to use application layer protocol negotiation (ALPN) to negotiate the use of HTTP/2.

HTTP/2 WebSockets are a bit different from HTTP/1.1 WebSockets. In HTTP/1, the client sends a `GET` request with the `upgrade:` header. In HTTP/2, the client sends a `CONNECT` request with the `:protocol` pseud-header. The Rails routes must be adjusted to accept both methods:

~~~ ruby
Rails.application.routes.draw do
	# Previously it was this:
	# get "home/index"
	match "home/index", to: "home#index", via: [:get, :connect]
end
~~~

Once this is done, you need to bind falcon to an `https` endpoint:

~~~ bash
$ falcon serve --bind "https://localhost:3000"
~~~

It's a bit more tricky to test this, but you can do so with the following Ruby code:

~~~ ruby
require 'async/http/endpoint'
require 'async/websocket/client'

endpoint = Async::HTTP::Endpoint.parse("https://localhost:3000/home/index")

Async do
	internet = Async::HTTP::Internet.new
	response = internet.connect("https://localhost:3000/home/index")
	binding.irb
end

Async::WebSocket::Client.connect(endpoint) do |connection|
	puts connection.framer.connection.class
	# Async::HTTP::Protocol::HTTP2::Client
	
	while message = connection.read
		puts message.inspect
	end
end
~~~
