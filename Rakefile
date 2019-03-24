require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

import 'tasks/lint.rake'
import 'tasks/release.rake'

task default: [:spec, :lint]

task :console do
  require 'irb'
  require 'irb/completion'

  require 'pry'
  require 'arbre'

  ARGV.clear
  IRB.start
end
