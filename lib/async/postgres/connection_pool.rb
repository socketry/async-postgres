require_relative 'queue'

module Async
	module Postgres
		class ConnectionPool < ActiveRecord::ConnectionAdapters::ConnectionPool
			def initialize(*)
				super
				@available = Async::Postgres::Queue.new(self)
			end
		end
	end
end
