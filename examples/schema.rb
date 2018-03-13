
gem 'pg', '~> 0.18'

if defined?(Falcon)
	$stderr.puts "Loading async/postgres"
	require_relative '../lib/async/postgres'
end

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "test", pool: 1024)
# ActiveRecord::Base.logger = Logger.new(STDOUT)
