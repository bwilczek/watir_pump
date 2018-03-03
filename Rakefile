# frozen_string_literal: true

require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: %w[inspections]

RuboCop::RakeTask.new(:rubocop)
RSpec::Core::RakeTask.new(:rspec)

task :inspections do
  Rake::Task['rubocop'].execute
  Rake::Task['rspec'].execute
end

task :build do
  sh 'rm -rf watir_pump-*.gem'
  sh 'gem build watir_pump.gemspec'
end

task :release do
  sh 'gem push watir_pump-*.gem'
end
