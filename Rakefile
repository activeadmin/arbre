# frozen_string_literal: true
require 'bundler'
Bundler::GemHelper.install_tasks

import "tasks/gemfiles.rake"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :console do
  require 'irb'
  require 'irb/completion'

  require 'pry'
  require 'arbre'

  ARGV.clear
  IRB.start
end
