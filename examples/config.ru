
require_relative 'schema'

run lambda {|env|
	10.times do
		ActiveRecord::Base.connection.execute("SELECT pg_sleep(0.01)")
	end
	
	ActiveRecord::Base.clear_active_connections!
	
	[200, {}, []]
}
