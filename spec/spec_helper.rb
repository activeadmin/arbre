require 'bundler/setup'
require 'arbre'

def arbre(&block)
  Arbre::Context.new assigns, helpers, &block
end
