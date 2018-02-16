
require_relative "lib/async/postgres/version"

Gem::Specification.new do |spec|
	spec.name          = "async-postgres"
	spec.version       = Async::Postgres::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]

	spec.summary       = %q{Access postgres without blocking.}
	spec.homepage      = "https://github.com/socketry/async-postgres"

	spec.files         = `git ls-files -z`.split("\x0").reject do |f|
		f.match(%r{^(test|spec|features)/})
	end
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.require_paths = ["lib"]

	spec.add_dependency "async"
	spec.add_dependency "pg"

	spec.add_development_dependency "async-rspec"

	spec.add_development_dependency "bundler", "~> 1.16"
	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec", "~> 3.0"
end
