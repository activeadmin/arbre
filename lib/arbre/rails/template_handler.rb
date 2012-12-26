module Arbre
  module Rails
    class TemplateHandler
      def call(template)
        <<-END
        Arbre::Context.new(assigns, self) {
          #{template.source}
        }.to_s
        END
      end
    end
  end
end

ActionView::Template.register_template_handler :arb, Arbre::Rails::TemplateHandler.new
