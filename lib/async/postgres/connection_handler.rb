require_relative 'connection_pool'

module Async
	module Postgres
		class ConnectionHandler < ActiveRecord::ConnectionAdapters::ConnectionHandler
			def establish_connection(config)
				resolver = ConnectionSpecification::Resolver.new(Base.configurations)
				spec = resolver.spec(config)

				remove_connection(spec.name)

				message_bus = ActiveSupport::Notifications.instrumenter
				payload = {
					connection_id: object_id
				}
				if spec
					payload[:spec_name] = spec.name
					payload[:config] = spec.config
				end

				message_bus.instrument("!connection.active_record", payload) do
					owner_to_pool[spec.name] = Async::Postgres::ConnectionPool.new(spec)
				end

				owner_to_pool[spec.name]
			end
		end
	end
end
