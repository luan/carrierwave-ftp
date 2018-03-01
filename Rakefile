require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Bundler::GemHelper.install_tasks

desc 'Run all examples'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

task default: %i[rubocop spec]
