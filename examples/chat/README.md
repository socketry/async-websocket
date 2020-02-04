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

### Fiber Performance

To improve fiber performance:

	export RUBY_FIBER_VM_STACK_SIZE=0
	export RUBY_FIBER_MACHINE_STACK_SIZE=0
	export RUBY_SHARED_FIBER_POOL_FREE_STACKS=0

`RUBY_SHARED_FIBER_POOL_FREE_STACKS` is an experimental feature on `ruby-head`.

### FiberError: can't set a guard page: Cannot allocate memory

This error occurs because the operating system has limited resources for allocating fiber stacks.

You can find the current limit:

	% sysctl vm.max_map_count
	vm.max_map_count = 65530

You can increase it:

	% sysctl -w vm.max_map_count=2500000

## Logs

### 2020

```
koyoko% ./multi-client.rb -c 100000
 0.15s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:11:39 +1300]
               | Made 1 connections: 202.88 connections/second...
 0.15s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:11:39 +1300]
               | GC.start duration=0.0s GC.count=27
 8.82s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:11:47 +1300]
               | Made 10001 connections: 1152.85 connections/second...
 8.89s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:11:47 +1300]
               | GC.start duration=0.06s GC.count=28
 17.7s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:11:56 +1300]
               | Made 20001 connections: 1139.39 connections/second...
17.84s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:11:56 +1300]
               | GC.start duration=0.14s GC.count=29
26.71s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:05 +1300]
               | Made 30001 connections: 1129.44 connections/second...
 26.9s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:05 +1300]
               | GC.start duration=0.19s GC.count=30
35.97s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:14 +1300]
               | Made 40001 connections: 1116.59 connections/second...
36.22s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:15 +1300]
               | GC.start duration=0.25s GC.count=31
45.41s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:24 +1300]
               | Made 50001 connections: 1104.74 connections/second...
45.65s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:24 +1300]
               | GC.start duration=0.24s GC.count=32
54.94s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:33 +1300]
               | Made 60001 connections: 1095.18 connections/second...
 55.3s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:34 +1300]
               | GC.start duration=0.37s GC.count=33
  1m4s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:43 +1300]
               | Made 70001 connections: 1085.98 connections/second...
  1m5s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:43 +1300]
               | GC.start duration=0.44s GC.count=34
 1m14s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:53 +1300]
               | Made 80001 connections: 1074.6 connections/second...
 1m14s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:12:53 +1300]
               | GC.start duration=0.36s GC.count=35
 1m24s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:13:03 +1300]
               | Made 90001 connections: 1066.37 connections/second...
 1m24s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:13:03 +1300]
               | GC.start duration=0.35s GC.count=36
 1m34s     info: Command [oid=0x2f8] [pid=820099] [2020-02-04 23:13:13 +1300]
               | Finished top level connection loop...
```

### 2019

This report is affected by `tty-progressbar` bugs.

```
koyoko% bundle exec ./multi-client.rb --count 100000
145.94 connection/s [                                                                                                         ] 1/100000 ( 6s/ 0s)
 0.11s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:29:58 +1200]
               | GC.start -> 0.01s
591.10 connection/s [==========                                                                                        ] 10001/100000 ( 1m52s/12s)
12.92s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:30:11 +1200]
               | GC.start -> 0.3s
455.06 connection/s [====================                                                                              ] 20001/100000 ( 1m42s/25s)
26.17s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:30:24 +1200]
               | GC.start -> 0.45s
294.11 connection/s [=============================                                                                     ] 30001/100000 ( 1m31s/39s)
39.95s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:30:38 +1200]
               | GC.start -> 0.68s
153.08 connection/s [=======================================                                                           ] 40001/100000 ( 1m19s/53s)
 53.9s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:30:52 +1200]
               | GC.start -> 0.8s
23.03 connection/s [================================================                                                ] 50001/100000 ( 1m 7s/ 1m 7s)
  1m8s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:31:07 +1200]
               | GC.start -> 0.95s
0.87552 connection/s [==========================================================                                       ] 60001/100000 (55s/ 1m23s)
 1m24s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:31:23 +1200]
               | GC.start -> 1.04s
0.74375 connection/s [====================================================================                             ] 70001/100000 (43s/ 1m42s)
 1m43s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:31:42 +1200]
               | GC.start -> 1.17s
0.64832 connection/s [==============================================================================                   ] 80001/100000 (30s/ 2m 2s)
  2m4s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:32:02 +1200]
               | GC.start -> 1.29s
0.57842 connection/s [=======================================================================================          ] 90001/100000 (16s/ 2m26s)
 2m27s     info: #<Command:0x000055de596579e8> [pid=14815] [2019-07-08 00:32:26 +1200]
               | GC.start -> 1.55s
435.05 connection/s [=================================================================================================] 100000/100000 ( 0s/ 2m50s)
```
