# frozen_string_literal: true
module Arbre
  module Rails
    module Rendering

      def render(*args, &block)
        rendered = helpers.render(*args, &block)
        case rendered
        when Arbre::Context
          current_arbre_element.add_child rendered
        else
          text_node rendered
        end
      end
    end
  end
end
