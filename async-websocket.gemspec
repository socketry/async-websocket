# frozen_string_literal: true

require_relative "lib/async/websocket/version"

Gem::Specification.new do |spec|
	spec.name = "async-websocket"
	spec.version = Async::WebSocket::VERSION
	
	spec.summary = "An async websocket library on top of websocket-driver."
	spec.authors = ["Samuel Williams", "destructobeam", "Olle Jonsson", "Thomas Morgan", "Aurora Nockert", "Bryan Powell", "Emily Love Mills", "Gleb Sinyavskiy", "Janko Marohnić", "Juan Antonio Martín Lucas", "Michel Boaventura", "Peter Runich"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/async-websocket"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/async-websocket/",
		"funding_uri" => "https://github.com/sponsors/ioquatix",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.0"
	
	spec.add_dependency "async-http", "~> 0.54"
	spec.add_dependency "async-io", "~> 1.23"
	spec.add_dependency "protocol-rack", "~> 0.1"
	spec.add_dependency "protocol-websocket", "~> 0.11"
end
