
require_relative 'schema'

run lambda {|env|
	connection_pool = ActiveRecord::Base.connection_pool
	connection = connection_pool.checkout(10)
	
	10.times do
		connection.execute("SELECT pg_sleep(1)")
	end
	
	connection_pool.checkin(connection)
	# ActiveRecord::Base.clear_active_connections!
	
	[200, {}, ["Asynchronous Postgres\n"]]
}
