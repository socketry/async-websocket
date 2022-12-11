# Rails Integration

This guide explains how to use `async-websocket` with `falcon`.

## Project Setup

Firstly, we will create a new project for the purpose of this guide:

~~~ bash
$ rails new websockets
--- snip ---
~~~

Then, we need to add the [Falcon](https://github.com/socketry/falcon) web server and the `Async::WebSocket` gem:

~~~ bash
$ bundle add falcon async-websocket
$ bundle remove puma
--- snip ---
$ rails s
=> Booting Falcon
=> Rails 6.0.3.1 application starting in development http://localhost:3000
=> Run `rails server --help` for more startup options
~~~

## Adding the WebSocket Controller

Firstly, generate the controller with a single method:

~~~ bash
$ rails generate controller home index
~~~

Then edit your controller implementation:

~~~ ruby
require 'async/websocket/adapters/rack'

class HomeController < ApplicationController
	def index
		self.response = Async::WebSocket::Adapters::Rack.open(request.env) do |connection|
			connection.write({message: "Hello World"})
		end
	end
end
~~~

### Testing

You can quickly test that the above controller is working using a websocket client:
