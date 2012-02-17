module Arbre
  module Rails
    module Rendering

      def render(*args)
        rendered = helpers.render(*args)
        case rendered
        when Arbre::Context
          current_dom_context.add_child rendered
        else
          text_node rendered
        end
      end

    end
  end
end
