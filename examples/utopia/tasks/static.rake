
namespace :static do
	task :static_environment do
		RACK_ENV ||= :static
		DATABASE_ENV ||= :production
		SERVER_PORT ||= 9291
	end

	desc "Generate a static copy of the site."
	task :generate => [:static_environment, :environment] do
		require 'falcon/server'
		require 'async/io'
		require 'async/container'
		
		config_path = SITE_ROOT + 'config.ru'
		container_class = Async::Container::Threaded
		
		app, options = Rack::Builder.parse_file(config_path.to_s)
		
		container = container_class.new(concurrency: 2) do
			server = Falcon::Server.new(app, [
				Async::IO::Endpoint.parse("tcp://localhost:#{SERVER_PORT}", reuse_port: true)
			])
			
			server.run
		end
		
		output_path = ENV.fetch('OUTPUT_PATH') {SITE_ROOT + 'static'}
		
		# Delete any existing stuff:
		FileUtils.rm_rf(output_path)
		
		# Copy all public assets:
		Dir.glob(SITE_ROOT + 'public/*').each do |path|
			FileUtils.cp_r(path, output_path)
		end
		
		# Generate HTML pages:
		system("wget", "--mirror", "--recursive", "--continue", "--convert-links", "--adjust-extension", "--no-host-directories", "--directory-prefix", output_path.to_s, "http://localhost:#{SERVER_PORT}")
		
		container.stop
	end
end
