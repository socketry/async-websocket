
desc 'Set up the environment for running your web application'
task :environment do |task|
	require SITE_ROOT + 'config/environment'
	
	# We ensure this is part of the shell environment so if other commands are invoked they will work correctly.
	ENV['RACK_ENV'] = RACK_ENV.to_s if defined?(RACK_ENV)
	ENV['DATABASE_ENV'] = DATABASE_ENV.to_s if defined?(DATABASE_ENV)
	
	# This generates a consistent session secret if one was not already provided:
	if ENV['UTOPIA_SESSION_SECRET'].nil?
		require 'securerandom'
		
		warn 'Generating transient session key for development...'
		ENV['UTOPIA_SESSION_SECRET'] = SecureRandom.hex(32)
	end
end
