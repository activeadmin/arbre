# frozen_string_literal: true
require_relative 'rails/template_handler'
require_relative 'rails/forms'
require_relative 'rails/rendering'
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
