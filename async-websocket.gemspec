# frozen_string_literal: true

require_relative "lib/async/websocket/version"

Gem::Specification.new do |spec|
	spec.name = "async-websocket"
	spec.version = Async::WebSocket::VERSION
	
	spec.summary = "An async websocket library on top of websocket-driver."
	spec.authors = ["Samuel Williams", "destructobeam", "Olle Jonsson", "Aurora Nockert", "Bryan Powell", "Gleb Sinyavskiy", "Janko Marohnić", "Juan Antonio Martín Lucas", "Michel Boaventura"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/async-websocket"
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "async-http", "~> 0.54"
	spec.add_dependency "async-io", "~> 1.23"
	spec.add_dependency "protocol-rack", "~> 0.1"
	spec.add_dependency "protocol-websocket", "~> 0.10"
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "sus", "~> 0.18"
	spec.add_development_dependency "sus-fixtures-async-http", "~> 0.2.3"
end
