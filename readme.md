# Async::WebSocket

An asynchronous websocket client/server implementation for [HTTP/1](https://tools.ietf.org/html/rfc6455) and [HTTP/2](https://tools.ietf.org/html/rfc8441).

[![Development Status](https://github.com/socketry/async-websocket/workflows/Test/badge.svg)](https://github.com/socketry/async-websocket/actions?workflow=Test)

## Usage

Please see the [project documentation](https://socketry.github.io/async-websocket/) for more details.

  - [Getting Started](https://socketry.github.io/async-websocket/guides/getting-started/index) - This guide shows you how to implement a basic client and server.

  - [Rails Integration](https://socketry.github.io/async-websocket/guides/rails-integration/index) - This guide explains how to use `async-websocket` with Rails.

## Releases

Please see the [project releases](https://socketry.github.io/async-websocket/releases/index) for all releases.

### v0.30.1

### v0.30.0

  - Improved error handling.
  - Modernized the gem and refreshed dependencies.

### v0.29.1

  - Improved `connection&.close` handling.

### v0.29.0

  - Added nonce processing to HTTP/2 WebSockets for HTTP/1 proxy compatibility.

### v0.28.0

  - Added `ConnectionError` with access to the failed response.

### v0.27.0

  - Updated the Rails integration guide summary.
  - Modernized the gem and refreshed dependencies.

### v0.26.2

  - Compared requested WebSocket protocols case-insensitively.
  - Updated the Binance, chat, MUD, and Rack examples.
  - Improved documentation, including the Rails integration guide.
  - Removed obsolete Polygon.io and Utopia examples.

### v0.26.1

  - Removed the direct dependency on `async-io`.
  - Updated the `sus-fixtures-async-http` dependency.

### v0.26.0

  - Improved validation of WebSocket requests.
  - Ensured HTTP/2 requests include the `:scheme` pseudo-header.
  - Improved HTTP/1 stream checks.
  - Fixed arguments passed to 404 responses.
  - Updated documentation and links.

### v0.25.1

  - Updated the minimum `protocol-websocket` version.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Running Tests

To run the test suite:

``` shell
bundle exec sus
```

### Making Releases

To make a new release:

``` shell
bundle exec bake gem:release:patch # or minor or major
```

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
