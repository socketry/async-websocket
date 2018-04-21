
task :log do
	require 'utopia/logger'
	LOGGER = Utopia::Logger.new
end

namespace :log do
	desc "Increase verbosity of logger to info."
	task :info => :log do
		LOGGER.level = Logger::INFO
	end

	desc "Increase verbosity of global debug."
	task :debug => :log do
		LOGGER.level = Logger::DEBUG
	end
end
