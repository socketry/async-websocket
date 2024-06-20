# Rack Example

This example shows how to host a WebSocket server using Rack.

## Usage

Install the dependencies:

~~~ bash
$ bundle update
~~~

Then start the server:

~~~ bash
$ bundle exec falcon serve --bind "http://localhost:9292"
~~~

You can connect to the server using a WebSocket client:

~~~ bash
$ bundle exec ./client.rb "http://localhost:9292"
~~~

### Using Puma

You can also use Puma to host the server:

~~~ bash
$ bundle exec puma --bind "tcp://localhost:9292"
~~~

The command for running the client is the same.
