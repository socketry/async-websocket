
require_relative "lib/async/websocket/version"

Gem::Specification.new do |spec|
	spec.name = "async-websocket"
	spec.version = Async::WebSocket::VERSION
	
	spec.summary = "An async websocket library on top of websocket-driver."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/async-websocket"
	
	spec.files = Dir['{lib}/**/*', base: __dir__]

	spec.required_ruby_version = ">= 0"
	
	spec.add_dependency "async-http", "~> 0.51"
	spec.add_dependency "async-io", "~> 1.23"
	spec.add_dependency "protocol-websocket", "~> 0.7.0"
	
	spec.add_development_dependency "async-rspec"
	spec.add_development_dependency "bake-bundler"
	spec.add_development_dependency "bake-modernize"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "falcon", "~> 0.34"
	spec.add_development_dependency "rack-test"
	spec.add_development_dependency "rspec", "~> 3.6"
	spec.add_development_dependency "utopia-project"
end
