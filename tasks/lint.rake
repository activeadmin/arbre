require "open3"

#
# Common stuff for a linter
#
module LinterMixin
  def run
    offenses = []

    applicable_files.each do |file|
      if clean?(file)
        print "."
      else
        offenses << file
        print "F"
      end
    end

    print "\n"

    return if offenses.empty?

    raise failure_message_for(offenses)
  end

  private

  def applicable_files
    Open3.capture2("git grep -Il ''")[0].split
  end

  def failure_message_for(offenses)
    msg = "#{self.class.name} detected offenses. "

    msg += if respond_to?(:fixing_cmd)
             "Run `#{fixing_cmd(offenses)}` to fix them."
           else
             "Affected files: #{offenses.join(' ')}"
           end

    msg
  end
end

#
# Checks trailing new lines in files
#
class MissingTrailingCarriageReturn
  include LinterMixin

  def clean?(file)
    File.read(file) =~ /\n\Z/m
  end
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new

desc "Lints ActiveAdmin code base"
task lint: ["rubocop", "lint:missing_trailing_carriage_return"]

namespace :lint do
  desc "Check for missing trailing new lines"
  task :missing_trailing_carriage_return do
    puts "Checking for missing trailing carriage returns..."

    MissingTrailingCarriageReturn.new.run
  end
end
