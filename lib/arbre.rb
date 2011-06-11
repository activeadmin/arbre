require "arbre/html"
require "arbre/attributes"
require "arbre/core_extensions"
require "arbre/element"
require "arbre/context"
require "arbre/collection"
require "arbre/class_list"
require "arbre/tag"
require "arbre/document"
require "arbre/html5_elements"
require "arbre/text_node"
require "arbre/version"

# Arbre - The DOM Tree in Ruby
#
# Arbre is a ruby library for building HTML in pure Object Oriented Ruby
module Arbre
end

require 'action_view'

ActionView::Template.register_template_handler :arb, lambda { |template|
  "self.class.send :include, Arbre::HTML; @_helpers = self; begin; #{template.source}; end; current_dom_context"
}
