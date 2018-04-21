
desc 'Run by git post-update hook when deployed to a web server'
task :deploy do
	# This task is typiclly run after the site is updated but before the server is restarted.
end

desc 'Restart the application server'
task :restart do
	# This task is run after the deployment task above.
	if passenger_config = `which passenger-config`.chomp!
		sh(passenger_config, 'restart-app', '--ignore-passenger-not-running', SITE_ROOT.to_s)
	end
end
