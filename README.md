# Async::WebSocket

A simple asynchronous websocket client/server implementation.

[![Build Status](https://secure.travis-ci.org/socketry/async-websocket.svg)](http://travis-ci.org/socketry/async-websocket)
[![Code Climate](https://codeclimate.com/github/socketry/async-websocket.svg)](https://codeclimate.com/github/socketry/async-websocket)
[![Coverage Status](https://coveralls.io/repos/socketry/async-websocket/badge.svg)](https://coveralls.io/r/socketry/async-websocket)

## Installation

Add this line to your application's Gemfile:

	gem 'async-websocket'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install async-websocket

## Usage

There are [examples](examples/) which include:

- [A command line chat client and application server](examples/chat/client.rb) which can read input from `stdin` and send messages to the server.
- [A utopia-based web application](examples/utopia) which uses a JavaScript client to connect to a web application server.

### Client Side with Async

```ruby
#!/usr/bin/env ruby

require 'async'
require 'async/io/stream'
require 'async/http/url_endpoint'
require 'async/websocket/client'

USER = ARGV.pop || "anonymous"
URL = ARGV.pop || "ws://localhost:9292"

Async do |task|
	endpoint = Async::HTTP::URLEndpoint.parse(URL)
	headers = {'token' => 'wubalubadubdub'}
	
	endpoint.connect do |socket|
		connection = Async::WebSocket::Client.new(socket, URL, headers)
		
		connection.send_message({
			user: USER,
			status: "connected",
		})
		
		while message = connection.next_message
			puts message.inspect
		end
	end
end
```

### Server Side with Rack & Falcon

```ruby
#!/usr/bin/env falcon serve --concurrency 1 -c

require 'async/websocket/server'

$connections = []

run lambda {|env|
	Async::WebSocket::Server.open(env) do |connection|
		$connections << connection
		
		while message = connection.next_message
			$connections.each do |connection|
				connection.send_message(message)
			end
		end
	end
	
	[200, {}, ["Hello World"]]
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2015, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
