
require 'async/postgres/connection'

RSpec.describe Async::Postgres::Connection do
	include_context Async::RSpec::Reactor
	
	let(:connection_string) {"host=localhost dbname=test"}
	let(:connection) {Async::Postgres::Connection.new(connection_string)}
	
	it "should execute query" do
		reactor.async do
			results = connection.async_exec("SELECT 42 AS LIFE")
		
			expect(results.each.to_a).to be == [{"life" => "42"}]
			
			connection.close
		end
	end

	it "should behave like real connection" do
		reactor.async do
			expect(connection.respond_to?(:conninfo)).to be true
			
			connection.close
		end
	end
end
