require 'async/reactor'

module Async
	class Reactor < Node
		attr_accessor :postgres_pools
	end
end
