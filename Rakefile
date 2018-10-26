require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: [:spec, :rubocop]

task :console do
  require 'irb'
  require 'irb/completion'

  require 'pry'
  require 'arbre'

  ARGV.clear
  IRB.start
end
