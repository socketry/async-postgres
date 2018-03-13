# Async::Postgres

This is an experimental drop in wrapper to make Postgres work asynchronously.

## Motivation

We have some IO bound web APIs generating statistics and we sometimes have issues when using [passenger] due to thread/process exhaustion.

In addition, we make a lot of upstream HTTP RPCs and these are also IO bound.

This library, in combination with [async-http], ensure that we don't become IO bound in many cases. In addition, we don't need to tune the intermediate server as it will simply scale according to backend resource availability and IO throughput.

[passenger]: https://github.com/phusion/passenger
[async-http]: https://github.com/socketry/async-http

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'async-postgres'
```

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install async-postgres

## Performance

For database-bound workloads, this approach yields significant improvements to throughput and ultimately latency.

Using the example provided, which sleeps in the database for 10x10ms, we expect 10 sequential requests/second:

```ruby
run lambda {|env|
	10.times do
		ActiveRecord::Base.connection.execute("SELECT pg_sleep(0.01)")
	end
	
	ActiveRecord::Base.clear_active_connections!
	
	[200, {}, []]
}
```

When running on [puma], with 16 threads, we could expect roughly 16 threads * 10 sequential requests/second.

```
% puma
Puma starting in single mode...
* Version 3.11.2 (ruby 2.5.0-p0), codename: Love Song
* Min threads: 0, max threads: 16
* Environment: development
* Listening on tcp://0.0.0.0:9292
Use Ctrl-C to stop

% wrk -c 512 -t 128 -d 30 http://localhost:9292
Running 30s test @ http://localhost:9292
  128 threads and 512 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   105.77ms    4.05ms 176.61ms   98.61%
    Req/Sec    37.83      5.64    40.00     84.64%
  4544 requests in 30.09s, 230.75KB read
Requests/sec:    151.00
Transfer/sec:      7.67KB
```

We can see we get close to the theoretical throughput given the number of available threads.

If we start [puma] with more threads, we get increased throughput.

```
% puma -t 128:128 
Puma starting in single mode...
* Version 3.11.2 (ruby 2.5.0-p0), codename: Love Song
* Min threads: 128, max threads: 128
* Environment: development
* Listening on tcp://0.0.0.0:9292
Use Ctrl-C to stop

% wrk -c 512 -t 128 -d 30 http://localhost:9292
Running 30s test @ http://localhost:9292
  128 threads and 512 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   153.92ms   27.06ms 597.36ms   95.11%
    Req/Sec    26.34      9.14    40.00     70.04%
  24985 requests in 30.10s, 1.24MB read
  Socket errors: connect 0, read 49, write 0, timeout 0
Requests/sec:    830.06
Transfer/sec:     42.15KB
```

The theoretical throughput in this case is 128 threads * 10 sequential requests/second. Unfortunately, [puma] in it's current configuration quickly becomes CPU bound:

```
% puma -t 512:512
Puma starting in single mode...
* Version 3.11.2 (ruby 2.5.0-p0), codename: Love Song
* Min threads: 512, max threads: 512
* Environment: development
* Listening on tcp://0.0.0.0:9292
Use Ctrl-C to stop

% wrk -c 512 -t 128 -d 30 http://localhost:9292
Running 30s test @ http://localhost:9292
  128 threads and 512 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   452.46ms   96.97ms   1.71s    80.84%
    Req/Sec    10.12      5.52    40.00     77.06%
  23343 requests in 30.10s, 1.16MB read
Requests/sec:    775.49
Transfer/sec:     39.38KB
```

When running with [falcon], we are limited by the database. Postgres has been configured with up to 1024 connections, and falcon runs one process per available (hyper-)core, 8 in this case. With up to 1024 connections, we could expect an upper bound of 512 connections * 10 sequential requests/second.

```
% falcon --quiet serve --forked

% wrk -c 512 -t 128 -d 30 http://localhost:9292
Running 30s test @ http://localhost:9292
  128 threads and 512 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   158.85ms   20.33ms 263.33ms   68.57%
    Req/Sec    25.25      8.97    40.00     72.16%
  96641 requests in 30.10s, 4.52MB read
Requests/sec:   3210.90
Transfer/sec:    153.65KB
```

We get close to the theoretical 5120 requests/second limit, but at this point the entire test becomes CPU bound within Ruby/Falcon.

## Usage

In theory, this is a drop-in replacement for ActiveRecord. But, it must be used with an [async] capable server like [falcon].

[falcon]: https://github.com/socketry/falcon
[puma]: https://github.com/puma/puma

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>

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
