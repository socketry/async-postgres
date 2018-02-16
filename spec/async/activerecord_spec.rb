
require 'active_record'

class Book < ActiveRecord::Base
end

RSpec.describe ActiveRecord do
	include_context Async::RSpec::Reactor
	
	it "should work using async adapter" do
		reactor.async do
			ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "test")
			ActiveRecord::Base.logger = Logger.new(STDOUT)
			
			ActiveRecord::Schema.define do
				create_table :books, force: true do |t|
					t.string :name
					t.timestamps
				end
			end
			
			Book.create(name: "How to use a fork")
			
			# This closes the underlying connection.
			ActiveRecord::Base.remove_connection
		end
	end
end
