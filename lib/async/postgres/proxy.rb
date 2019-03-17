require_relative 'patch_reactor'
require_relative 'pool'

module Async
	module Postgres
		class Proxy
			def initialize(connection_string, task: Task.current)
				@connection_string = connection_string

				pools = task.reactor.postgres_pools ||= {}

				@pool = pools[@connection_string] ||= Pool.new do
					Connection.new(@connection_string)
				end
			end

			def close
				@pool.close
			end

			def async_exec(*args)
				@pool.acquire do |connection|
					connection.async_exec(*args)
				end
			end

			def respond_to?(*args)
				@pool.acquire do |connection|
					connection.respond_to?(*args)
				end
			end

			def method_missing(*args, &block)
				@pool.acquire do |connection|
					connection.send(*args, &block)
				end
			end
		end
	end
end
