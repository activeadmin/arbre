module Arbre
  module ActionView
    class TemplateHandler
      def call(template)
        require 'arbre/html'

        <<-END
        Arbre::Context.new(assigns, self) do
          #{template.source}
        end.to_s
        END
      end
    end
  end
end