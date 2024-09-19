# frozen_string_literal: true
require 'active_support/core_ext/string/output_safety'
require 'active_support/hash_with_indifferent_access'
require 'active_support/inflector'

module Arbre
end

require_relative 'arbre/element'
require_relative 'arbre/context'
require_relative 'arbre/html/attributes'
require_relative 'arbre/html/class_list'
require_relative 'arbre/html/tag'
require_relative 'arbre/html/text_node'
require_relative 'arbre/html/document'
require_relative 'arbre/html/html5_elements'
require_relative 'arbre/component'

if defined?(Rails)
  require_relative 'arbre/railtie'
end
