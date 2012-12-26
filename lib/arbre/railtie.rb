module Arbre
  class Railtie < ::Rails::Railtie
    initializer 'arbre.initialize' do
      ::Arbre::Element.send :include, Arbre::ActionView::Rendering
      ::ActionView::Template.register_template_handler :arb, Arbre::ActionView::TemplateHandler.new
    end
  end
end