module Arbre
  module Rails

    class TemplateHandler

      def call(template)
        "Arbre::Context.new(assigns, self){ #{template.source} }.to_s"
      end

    end

  end
end

ActionView::Template.register_template_handler :arb, Arbre::Rails::TemplateHandler.new
