# Example WebSocket Chat Server

This is a simple chat client/server implementation with specs.

## Starting Development Server

To start the development server, simply execute

	> rake
	Generating transient session key for development...
	20:57:36 - INFO - Starting Falcon HTTP server on localhost:9292
	20:57:36 - INFO - Guard::RSpec is running
	20:57:36 - INFO - Guard is now watching at '...'
	[1] guard(main)>

Then browse http://localhost:9292 (or as specified) to see your new site.

## Inspecting with `wscat`

If you are running a local instance of the server, you can connect to it using `wscat`:

```bash
$ wscat --ca ~/.localhost/localhost.crt --connect wss://localhost:9292/server/connect
Connected (press CTRL+C to quit)
< {"text":"Hello"}
```

Typing text into the web browser broadcasts it to all connected clients, including `wscat`.
