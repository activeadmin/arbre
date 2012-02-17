require 'active_support/core_ext/string/output_safety'
require 'active_support/hash_with_indifferent_access'
require 'active_support/inflector'

module Arbre
end

require 'arbre/element'
require 'arbre/context'
require 'arbre/html/attributes'
require 'arbre/html/class_list'
require 'arbre/html/tag'
require 'arbre/html/text_node'
require 'arbre/html/document'
require 'arbre/html/html5_elements'
require 'arbre/component'

if defined?(Rails)
  require 'arbre/rails'
end
