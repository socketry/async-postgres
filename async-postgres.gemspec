
require_relative 'lib/async/postgres/version'

Gem::Specification.new do |spec|
	spec.name          = "async-postgres"
	spec.version       = Async::Postgres::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	spec.summary       = %q{Access postgres without blocking.}
	spec.homepage      = "https://github.com/socketry/async-postgres"
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_dependency "async", "~> 1.3"
	spec.add_dependency "pg"

	spec.add_development_dependency "async-rspec"
	spec.add_development_dependency "activerecord"

	spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rspec", "~> 3.6"
	spec.add_development_dependency "rake"
end
