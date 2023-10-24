# frozen_string_literal: true
module Arbre
  class Component < Arbre::HTML::Div
    # By default components render a div
    def tag_name
      'div'
    end
  end
end
