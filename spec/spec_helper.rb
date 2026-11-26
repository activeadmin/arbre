# frozen_string_literal: true

if ENV.fetch('COVERAGE', false)
  require 'simplecov'
  require 'simplecov-cobertura'
  SimpleCov.start do
    minimum_coverage 90
    maximum_coverage_drop 0.2
    formatter SimpleCov::Formatter::CoberturaFormatter
  end
end

require 'support/bundle'
require 'combustion'
require 'arbre'
require 'support/arbre_helpers'

RSpec.configure do |config|
  config.include ArbreHelpers
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
