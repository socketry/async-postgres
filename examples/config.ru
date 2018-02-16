
require_relative 'schema'

run lambda {|env|
	ActiveRecord::Base.connection.execute("SELECT pg_sleep(2)")
	
	[200, {}, []]
}
