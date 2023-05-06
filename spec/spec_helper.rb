# frozen_string_literal: true

if ENV.fetch('COVERAGE', false)
  require 'simplecov'
  require 'simplecov-cobertura'
  SimpleCov.start do
    add_filter %r{^/spec/}
    minimum_coverage 90
    maximum_coverage_drop 0.2
    formatter SimpleCov::Formatter::CoberturaFormatter
  end
end

require 'support/bundle'
require 'combustion'
require 'arbre'

def arbre(&block)
  Arbre::Context.new assigns, helpers, &block
end
