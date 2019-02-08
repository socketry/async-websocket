
require_relative 'lib/async/websocket/version'

Gem::Specification.new do |spec|
	spec.name          = "async-websocket"
	spec.version       = Async::WebSocket::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	spec.summary       = %q{An async websocket library on top of websocket-driver.}
	spec.homepage      = ""
	spec.license       = "MIT"

	spec.files         = `git ls-files -z`.split("\x0")
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_dependency "websocket-driver", "~> 0.7.0"

	spec.add_dependency "async-io"
	
	spec.add_development_dependency "async-rspec"
	spec.add_development_dependency "falcon", "~> 0.17"
	
	spec.add_development_dependency "covered"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "rspec", "~> 3.6"
	spec.add_development_dependency "rake"
end
