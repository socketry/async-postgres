require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test)

task :default => :test

task :console do
	require 'pry'
	
	require_relative 'lib/ffi/postgres'
	
	Pry.start
end