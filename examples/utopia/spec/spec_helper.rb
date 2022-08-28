# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'bundler/setup'
require 'covered/rspec'
require 'variant'

Variant.force!(:testing)

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = '.rspec_status'

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end
