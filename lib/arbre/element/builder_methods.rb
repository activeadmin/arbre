module Arbre
  class Element

    module BuilderMethods

      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods

        def builder_method(method_name)
          BuilderMethods.class_eval <<-EOF, __FILE__, __LINE__
            def #{method_name}(*args, &block)
              insert_tag ::#{self.name}, *args, &block
            end
          EOF
        end

      end

      def build_tag(klass, *args, &block)
        tag = klass.new(arbre_context)
        tag.parent = current_dom_context

        # If you passed in a block and want the object
        if block_given? && block.arity > 0
          # Set out context to the tag, and pass responsibility to the tag
          with_current_dom_context tag do
            tag.build(*args, &block)
          end
        else
          # Build the tag
          tag.build(*args)

          # Render the blocks contents
          if block_given?
            with_current_dom_context tag do
              append_return_block(yield)
            end
          end
        end

        tag
      end

      def insert_tag(klass, *args, &block)
        tag = build_tag(klass, *args, &block)
        current_dom_context.add_child(tag)
        tag
      end

      def current_dom_context
        arbre_context.current_dom_context
      end

      def with_current_dom_context(tag, &block)
        arbre_context.with_current_dom_context(tag, &block)
      end
      alias_method :within, :with_current_dom_context

      # Appends the value to the current DOM element if there are no
      # existing DOM Children and it responds to #to_s
      def append_return_block(tag)
        return nil if current_dom_context.children?

        if !tag.is_a?(Arbre::Element) && tag.respond_to?(:to_s)
          current_dom_context << Arbre::HTML::TextNode.from_string(tag.to_s)
        end
      end
    end

  end
end
