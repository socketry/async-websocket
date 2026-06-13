# Releases

## Unreleased

## v0.30.0

- Improved error handling.
- Modernized the gem and refreshed dependencies.

## v0.29.1

- Improved `connection&.close` handling.

## v0.29.0

- Added nonce processing to HTTP/2 WebSockets for HTTP/1 proxy compatibility.

## v0.28.0

- Added `ConnectionError` with access to the failed response.

## v0.27.0

- Updated the Rails integration guide summary.
- Modernized the gem and refreshed dependencies.

## v0.26.2

- Compared requested WebSocket protocols case-insensitively.
- Updated the Binance, chat, MUD, and Rack examples.
- Improved documentation, including the Rails integration guide.
- Removed obsolete Polygon.io and Utopia examples.

## v0.26.1

- Removed the direct dependency on `async-io`.
- Updated the `sus-fixtures-async-http` dependency.

## v0.26.0

- Improved validation of WebSocket requests.
- Ensured HTTP/2 requests include the `:scheme` pseudo-header.
- Improved HTTP/1 stream checks.
- Fixed arguments passed to 404 responses.
- Updated documentation and links.

## v0.25.1

- Updated the minimum `protocol-websocket` version.

## v0.25.0

- Allowed arguments to be passed through to `#close`.
- Improved close behavior.

## v0.24.0

- Used standard response handling for Rails.

## v0.23.1

- Relaxed the dependency on `protocol-websocket`.

## v0.23.0

- Ensured clients are closed when their connections are closed.
- Fixed the `Server` implementation.
- Removed an unused `@response` instance variable.
- Improved coverage for `Client`, `Connection`, `Response`, and dangling connection handling.
- Added early Rails documentation.

## v0.22.1

- Added a missing `protocol/rack/adapter` require.
- Updated the chat example for the message-based protocol interface.
- Migrated tests to `sus`.
- Updated examples for Rack 3 and high-connection-count usage.

## v0.22.0

- Removed default JSON parsing.
- Updated the connection interface to use message-based `read` and `write`.

## v0.21.0

- Added support for WebSocket extensions.

## v0.20.0

- Made protocol handling Falcon-agnostic.

## v0.19.2

- Removed an unused require.
- Modernized the gem.

## v0.19.1

- Made protocol upgrades case-insensitive.
- Used bound endpoints in server tests to avoid race conditions.
- Added an example using `wscat`.
- Adopted `bake-gem` for release management.

## v0.19.0

- Added an `http` adapter.
- Added a Binance HTTP/1 client example.
- Fixed client handling in `Client#connect`.
- Updated logging to use `Console.logger`.

## v0.18.0

- Added a Rails adapter.

## v0.17.0

- Added support for reconnecting after server disconnection.
- Updated keyword argument handling.
- Updated Utopia examples and dependencies.

## v0.16.0

- Always applied masking to client connections.
- Passed `endpoint.authority` through to `#connect`.
- Added a Polygon.io client example.
- Fixed `GC.count` logging.

## v0.15.0

- Improved connection handling and releasing connections back to the pool.
- Ensured Rack response headers are returned as a hash.
- Added static documentation.
- Modernized the gem and improved documentation.

## v0.14.0

- Reduced memory usage in high-connection-count examples.
- Avoided repeated `getaddrinfo` calls per connection.
- Added explicit connection management.
- Added documentation for `Client.open` and `Client.connect`.
- Improved HTTP/1 forcing, Rack, MUD, and Utopia examples.
- Added profiling support.
- Switched release tooling toward `bake-bundler`.

## v0.13.1

- Fixed HTTP/2 client output body handling.
- Added HTTP/2 WebSocket support to the chat example.
- Added message read/write coverage.

## v0.13.0

- Passed all options through to `connect`.

## v0.12.2

- Updated examples and documentation to use `Adapters::Rack`.
- Removed debug logging.
- Refreshed dependencies.

## v0.12.1

- Closed and flushed connections automatically when users did not close them explicitly.

## v0.12.0

- Added links to relevant RFCs and documented HTTP/2 support.
- Removed an unused response field.

## v0.11.1

- Fixed examples.

## v0.11.0

- Started support for both HTTP/1 and HTTP/2 WebSockets.
- Renamed `URLEndpoint` to `Endpoint`.
- Preferred `endpoint` terminology over `server_address`.
- Moved protocol constants into the protocol gem.
- Fixed client specs.

## v0.10.0

- Improved upgrade and masking handling.
- Allowed user-provided connection handlers.
- Refactored connection IO to use `Connection#read` and `Connection#write`.
- Added a simple MUD example.
- Removed the broken Utopia example.

## v0.9.0

- Switched to `protocol-websocket`.
- Added protocol negotiation and frame validation.
- Exposed the underlying socket.
- Improved client/server examples and EOF handling.
- Removed redundant headers.

## v0.8.0

- Added support for `sec-websocket-protocol` options.
- Added support for passing protocols and normalized client/server option handling.

## v0.7.0

- Set headers on WebSocket driver clients.
- Added more README examples.
- Preferred `Async do` in examples.

## v0.6.1

- Avoided closing connections from `Connection`; client and server lifecycle now close them explicitly.

## v0.6.0

- Improved handling of hijacked IO.

## v0.5.0

- Added a simple web-based chat app.
- Added partial support for Rack hijacking changes.
- Preferred `#readpartial` for input loops.
- Used the stream block size for reads.

## v0.4.1

- Handled `Errno::ECONNRESET`.

## v0.4.0

- Updated examples and documentation.
- Improved peer handling from call results.

## v0.3.0

- Added example chat client and server.
- Reworked legacy code and fixed specs.

## v0.2.0

- Renamed the gem to `async-websocket`.
- Tidied legacy socket lifetime management.
- Converted connection handling to sequential logic.
- Improved data stream handling.
- Handled EOF.

## v0.1.0

- Added the initial synchronous WebSocket implementation.
- Added specs and fixed early implementation issues.
