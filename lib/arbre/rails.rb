require 'arbre/rails/template_handler'
require 'arbre/rails/forms'
require 'arbre/rails/links'
require 'arbre/rails/rendering'

Arbre::Element.send :include, Arbre::Rails::Rendering
