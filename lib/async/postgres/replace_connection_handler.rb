require 'active_record'
require_relative 'connection_handler'

ActiveRecord::Base.default_connection_handler = Async::Postgres::ConnectionHandler.new
