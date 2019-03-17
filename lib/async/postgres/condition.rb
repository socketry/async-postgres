module Async
	module Postgres
		class Condition
			def initialize
				@waiters = []
			end

			# @param timeout [Number, NilClass]
			# @raise Async::TimeoutError
			def wait(timeout = nil)
				fiber = Fiber.current
				@waiters.push(fiber)

				Async::Task.current.with_timeout(timeout) do |timer|
					begin
						Async::Task.yield
						timer.cancel
					rescue Async::TimeoutError => e
						@waiters.delete(fiber)
						raise e
					end
				end if timeout
			end

			# @param immediate [Boolean]
			def signal(immediate = true)
				return if @waiters.empty?
				fiber = @waiters.shift
				signal unless fiber.alive?

				if immediate
					fiber.resume
				else
					Async::Task.current.reactor << fiber
				end

				nil
			end
		end
	end
end
