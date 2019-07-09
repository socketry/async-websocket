# The Journey to One Million

## Allocations per Connection

```
Array: 188498 allocations
Hash: 137041 allocations
String: 91387 allocations
Proc: 81242 allocations
Fiber: 30169 allocations
Async::Task: 30168 allocations
Async::IO::Buffer: 20904 allocations
Protocol::HTTP2::Window: 20162 allocations
Set: 20091 allocations
Async::Queue: 20082 allocations
Method: 20006 allocations
Protocol::HTTP::Headers::Merged: 10100 allocations
Protocol::HTTP::Headers: 10100 allocations
Async::Condition: 10002 allocations
Protocol::WebSocket::Framer: 10001 allocations
Async::HTTP::Body::Stream: 10001 allocations
Async::HTTP::Body::Hijack: 10001 allocations
Async::WebSocket::ConnectResponse: 10001 allocations
Async::WebSocket::Connection: 10001 allocations
Async::HTTP::Body::Writable: 10001 allocations
Async::HTTP::Protocol::HTTP2::Request::Stream: 10001 allocations
Async::HTTP::Protocol::HTTP2::Request: 10001 allocations
Falcon::Adapters::Input: 10001 allocations
Protocol::HTTP::Headers::Split: 10001 allocations
Async::HTTP::Protocol::HTTP2::Stream::Input: 10001 allocations
Async::HTTP::Protocol::HTTP2::Stream::Output: 10001 allocations
** 80.98830116988302 objects per connection.
```

## System Limits

### FiberError: can't set a guard page: Cannot allocate memory

This error occurs because the operating system has limited resources for allocating fiber stacks.

You can find the current limit:

	% sysctl vm.max_map_count
	vm.max_map_count = 65530

You can increase it:

	% sysctl -w vm.max_map_count=655300
