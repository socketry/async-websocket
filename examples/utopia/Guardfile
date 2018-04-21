
group :development do
	guard :falcon, port: 9292 do
		watch('Gemfile.lock')
		watch('config.ru')
		watch(%r{^config|lib|pages/.*})
		
		notification :off
	end
end

group :test do
	guard :rspec, cmd: 'rspec' do
		# Notifications can get a bit tedious:
		# notification :off
		
		# Re-run specs if they are changed:
		watch(%r{^spec/.+_spec\.rb$})
		watch('spec/spec_helper.rb') {'spec'}
		
		# Run relevent specs if files in `lib/` or `pages/` are changed:
		watch(%r{^lib/(.+)\.rb$}) {|match| "spec/lib/#{match[1]}_spec.rb" }
		watch(%r{^pages/(.+)\.(rb|xnode)$}) {|match| "spec/pages/#{match[1]}_spec.rb"}
		watch(%r{^pages/(.+)controller\.rb$}) {|match| Dir.glob("spec/pages/#{match[1]}*_spec.rb")}
		
		# If any files in pages changes, ensure the website still works:
		watch(%r{^pages/.*}) {'spec/website_spec.rb'}
	end
end
