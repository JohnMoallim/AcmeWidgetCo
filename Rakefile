# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

desc 'Run all tests with coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

desc 'Run all quality checks'
task quality: %i[rubocop spec]

desc 'Run examples'
task :examples do
  ruby 'run_examples.rb'
end

task default: :quality
