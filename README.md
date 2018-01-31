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

Here is how to use within `Utopia::Controller`:

	on 'list' do |request|
		fail! unless Async::WebSocket?(request.env)
		
		Async::WebSocket.open(request.env) do |connection|
			read, write = IO.pipe

			Process.spawn("ls -lah", :out => write)
			write.close

			read.each_line do |line|
				connection.text(line)
			end

			connection.close
		end
		
		succeed!
	end

`connection` is an instance of [`WebSocket::Driver`][1].

[1]: https://github.com/faye/websocket-driver-ruby

If you want to handle incoming messages, you must listen for these and then handle them:

	on 'echo' do |request|
		fail! unless Async::WebSocket?(request.env)
		
		Async::WebSocket.open(request.env) do |connection|
			connection.on(:message) do |event|
				connection.text(event.data)
				connection.close
			end
		end
		
		succeed!
	end

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
