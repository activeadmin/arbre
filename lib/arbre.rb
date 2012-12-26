require 'active_support/core_ext/string/output_safety'
require 'active_support/inflector'

module Arbre
  autoload :ActionView, 'arbre/action_view'
  autoload :Component, 'arbre/component'
  autoload :Context, 'arbre/context'
  autoload :Element, 'arbre/element'
  autoload :ElementCollection, 'arbre/element_collection'
  autoload :HTML, 'arbre/html'
end

require 'arbre/railtie' if defined?(Rails)
