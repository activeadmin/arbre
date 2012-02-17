$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path('../support', __FILE__)

require "bundler"
Bundler.setup

require 'arbre'

def arbre(&block)
  Arbre::Context.new assigns, helpers, &block
end
