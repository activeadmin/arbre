# frozen_string_literal: true
require 'arbre/rails/template_handler'
require 'arbre/rails/forms'
require 'arbre/rails/rendering'
require 'rails'

Arbre::Element.include(Arbre::Rails::Rendering)

module Arbre
  class Railtie < ::Rails::Railtie
    initializer "arbre" do
      ActiveSupport.on_load(:action_view) do
        ActionView::Template.register_template_handler :arb, Arbre::Rails::TemplateHandler.new
      end
    end
  end
end
