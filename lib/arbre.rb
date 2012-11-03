require 'active_support/core_ext/string/output_safety'
require 'active_support/inflector'

module Arbre
  autoload :Component, 'arbre/component'
  autoload :Context, 'arbre/context'
  autoload :Element, 'arbre/element'
  autoload :ElementCollection, 'arbre/element_collection'
  autoload :HTML, 'arbre/html'
end

require 'arbre/rails' if defined?(Rails)
