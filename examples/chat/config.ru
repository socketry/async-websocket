#!/usr/bin/env -S falcon serve --bind https://localhost:8080 --count 1 -c

require_relative '../../lib/async/websocket/adapters/rack'
require 'async/clock'
require 'async/semaphore'
require 'protocol/websocket/json_message'

require 'set'

# GC.disable

class Room
	def initialize
		@connections = Set.new
		@semaphore = Async::Semaphore.new(512)
		
		@count = 0
		@profile = nil
	end
	
	def connect connection
		@connections << connection
		
		@count += 1
		
		# if (@count % 10000).zero?
		# 	# (full_mark: false, immediate_sweep: false)
		# 	duration = Async::Clock.measure{GC.start}
		# 	Console.logger.info(self) {"GC.start duration=#{duration.round(2)}s GC.count=#{GC.count} @connections.count=#{@connections.count}"}
		# end
	end
	
	def disconnect connection
		@connections.delete(connection)
	end
	
	def each(&block)
		@connections.each(&block)
	end
	
	def allocations
		counts = Hash.new{|h,k| h[k] = 0}
		
		ObjectSpace.each_object do |object|
			counts[object.class] += 1
		end
		
		return counts
	end
	
	def show_allocations(key, limit = 1000)
		Console.logger.info(self) do |buffer|
			ObjectSpace.each_object(key).each do |object|
				buffer.puts object
			end
		end
	end
	
	def print_allocations(minimum = @connections.count)
		count = 0
		
		Console.logger.info(self) do |buffer|
			allocations.select{|k,v| v >= minimum}.sort_by{|k,v| -v}.each do |key, value|
				count += value
				buffer.puts "#{key}: #{value} allocations"
			end
			
			buffer.puts "** #{count.to_f / @connections.count} objects per connection."
		end
	end
	
	def start_profile
		require 'ruby-prof' unless defined?(RubyProf)
		
		return false if @profile
		
		@profile = RubyProf::Profile.new(merge_fibers: true)
		@profile.start
	end
	
	def stop_profile
		return false unless @profile
		
		result = @profile.stop
		printer = RubyProf::FlatPrinter.new(result)
		printer.print(STDOUT, min_percent: 0.5)
	
		# printer = RubyProf::GraphPrinter.new(result)
		# printer.print(STDOUT, min_percent: 0.5)
		
		@profile = nil
	end
	
	def command(code)
		Console.logger.warn self, "eval(#{code})"
		
		eval(code)
	end
	
	def broadcast(message)
		Console.logger.info "Broadcast: #{message.inspect}"
		start_time = Async::Clock.now
		
		@connections.each do |connection|
			@semaphore.async do
				connection.write(message)
				connection.flush
			end
		end
		
		end_time = Async::Clock.now
		Console.logger.info "Duration: #{(end_time - start_time).round(3)}s for #{@connections.count} connected clients."
	end
	
	def open(connection)
		self.connect(connection)
		
		if @connections.size == 1_000_000
			connection.write("Congratulations, you have completed the journey to one million! 🥳 👏👏👏🏼")
		end
		
		while message = connection.read
			event = Protocol::WebSocket::JSONMessage.wrap(message)&.to_h
			
			if event and event[:text] =~ /^\/(.*?)$/
				begin
					result = self.command($1)
					
					if result.is_a? Hash
						Protocol::WebSocket::JSONMessage.generate(result).send(connection)
					else
						Protocol::WebSocket::JSONMessage.generate({result: result}).send(connection)
					end
				rescue => error
					Protocol::WebSocket::JSONMessage.generate({error: error}).send(connection)
				end
			else
				self.broadcast(message)
			end
		end
		
		connection.close
	ensure
		self.disconnect(connection)
	end
	
	def call(env)
		Async::WebSocket::Adapters::Rack.open(env, &self.method(:open))
	end
end

run Room.new
