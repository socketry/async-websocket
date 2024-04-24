# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2024, by Samuel Williams.

source 'https://rubygems.org'

gemspec

# gem "protocol-websocket", path: "../protocol-websocket"

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
	
	gem "utopia-project"
end

group :test do
	gem "sus"
	gem "covered"
	
	gem "sus-fixtures-async-http"
	
	gem "bake-test"
	gem "bake-test-external"
end
