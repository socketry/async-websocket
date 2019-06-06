#!/usr/bin/env falcon serve --count 1 --bind http://127.0.0.1:7070 -c

require 'async/websocket/adapters/rack'

class Room
	def initialize(name, description = nil)
		@name = name
		@description = description
		
		@actions = {}
		@users = []
	end
	
	attr :name
	attr :description
	
	attr :actions
	
	def connect(key, room)
		@actions[key] = lambda do |user|
			self.exit(user)
			room.enter(user)
		end
		
		return room
	end
	
	def broadcast(message)
		@users.each do |user|
			user.write(message)
			user.flush
		end
	end
	
	def enter(user)
		user.notify("You have entered the #{@name}.")
		user.room = self
		
		@users << user
		
		@users.each do |user|
			user.notify("#{user.name} entered the room.")
		end
	end
	
	def exit(user)
		if @users.delete(user)
			@users.each do |user|
				user.notify("#{user.name} left the room.")
			end
		end
	end
	
	def as_json
		{
			name: @name,
			description: @description,
			actions: @actions.keys,
		}
	end
end

module Command
	def self.split(line)
		line.scan(/(?:"")|(?:"(.*[^\\])")|(\w+)/).flatten.compact
	end
end

class User < Async::WebSocket::Connection
	def initialize(*)
		super
		
		@name = name
		@room = nil
		@inventory = []
	end
	
	attr_accessor :room
	
	ANONYMOUS = "Anonymous"
	
	def name
		@name || ANONYMOUS
	end
	
	def handle(message)
		key, *arguments = Command.split(message[:input])
		case key
		when "name"
			@name = arguments.first
		when "look"
			self.write({room: @room.as_json})
		else
			if action = @room.actions[key]
				action.call(self, *arguments)
			else
				message[:user]
				@room.broadcast(message)
			end
		end
	end
	
	def notify(text)
		self.write({notify: text})
		self.flush
	end
	
	def close
		if @room
			@room.exit(self)
		end
		
		super
	end
end

class Server
	def initialize(app)
		@app = app
		
		@entrance = Room.new("Portal", "A vast entrance foyer with a flowing portal.")
		@entrance.connect("forward", Room.new("Training Room"))
		@entrance.connect("corridor", Room.new("Shop"))
	end
	
	def call(env)
		Async::WebSocket::Adapters::Rack.open(env, connect: User) do |user|
			@entrance.enter(user)
			
			while message = user.read
				user.handle(message)
			end
		ensure
			# Async.logger.error(self, $!) if $!
			user.close
		end or @app.call(env)
	end
end

use Server

run lambda {|env| [200, {}, []]}
