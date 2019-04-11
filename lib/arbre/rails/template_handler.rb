module Arbre
  module Rails
    class TemplateHandler
      def call(template, source = nil)
        source = template.source unless source

        <<-END
        Arbre::Context.new(assigns, self) {
          #{source}
        }.to_s
        END
      end
    end
  end
end

ActionView::Template.register_template_handler :arb, Arbre::Rails::TemplateHandler.new
