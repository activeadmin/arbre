# frozen_string_literal: true
require 'support/bundle'

require 'arbre'

def arbre(&block)
  Arbre::Context.new assigns, helpers, &block
end
