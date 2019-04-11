module Arbre
  module Rails
    module Links

      class LinkToProxy < Arbre::Component
        builder_method :link_to

        def build(name, options = nil, html_options = nil, &block)
          tag = Arbre::HTML::A.new(arbre_context)
          tag.parent = current_arbre_element

          link_to_string = helpers.link_to(name, options, html_options, &block)
          tag.add_child(link_to_string)

          @opening_tag, @closing_tag = split_string_on(link_to_string, "</a>")
        end

        def split_string_on(string, match)
          return "" unless string && match
          part_1 = string.split(Regexp.new("#{match}\\z")).first
          [part_1, match]
        end

        def opening_tag
          @opening_tag
        end

        def closing_tag
          @closing_tag
        end

      end

    end
  end
end
