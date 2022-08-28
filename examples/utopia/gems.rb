# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

source 'https://rubygems.org'

group :preload do
	gem 'utopia', '~> 2.20.0'
	# gem 'utopia-gallery'
	# gem 'utopia-analytics'
	
	gem 'thread-local'
	
	gem 'async-redis'
	gem 'async-websocket'
	
	gem 'db'
	gem 'db-postgres'
	
	gem 'variant'
end

gem 'rake'
gem 'bake'
gem 'bundler'
gem 'rack-test'
gem 'net-smtp'

group :development do
	gem 'guard-falcon', require: false
	gem 'guard-rspec', require: false
	
	gem 'rspec'
	gem 'covered'
	
	gem 'async-rspec'
	gem 'benchmark-http'
end

group :production do
	gem 'falcon'
end
