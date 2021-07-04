require_relative 'condition'

module Async
	module Postgres
		class Queue < ActiveRecord::ConnectionAdapters::ConnectionPool::ConnectionLeasingQueue
			def initialize(*)
				super
				@cond = Async::Postgres::Condition.new
			end

			def wait_poll(timeout)
				@num_waiting += 1
				t0 = Time.now

				ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
					@cond.wait(timeout)
				end
				return remove
			rescue Async::TimeoutError => _
				elapsed = Time.now - t0
				msg = "could not obtain a connection from the pool within %0.3f seconds (waited %0.3f seconds); all pooled connections were in use" %
					[timeout, elapsed]
				raise ActiveRecord::ConnectionTimeoutError, msg
			ensure
				@num_waiting -= 1
			end
		end
	end
end
