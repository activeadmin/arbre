# frozen_string_literal: true
require 'arbre/rails/template_handler'
require 'arbre/rails/forms'
require 'arbre/rails/rendering'

Arbre::Element.send :include, Arbre::Rails::Rendering
