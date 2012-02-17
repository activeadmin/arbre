module Arbre
  module Rails

    class TemplateHandler

      def self.call(template)
        new.call(template)
      end

      def call(template)
        "Arbre::Context.new(assigns, self){ #{template.source} }"
      end

    end

  end
end

ActionView::Template.register_template_handler :arb, Arbre::Rails::TemplateHandler
