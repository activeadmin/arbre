# frozen_string_literal: true
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
        tag.parent = current_arbre_element

        with_current_arbre_element tag do
          if block_given? && block.arity > 0
            tag.build(*args, &block)
          else
            tag.build(*args)
            append_return_block(yield) if block_given?
          end
        end

        tag
      end

      def insert_tag(klass, *args, &block)
        tag = build_tag(klass, *args, &block)
        current_arbre_element.add_child(tag)
        tag
      end

      def current_arbre_element
        arbre_context.current_arbre_element
      end

      def with_current_arbre_element(tag, &block)
        arbre_context.with_current_arbre_element(tag, &block)
      end
      alias_method :within, :with_current_arbre_element

      private

      # Appends the value to the current DOM element if there are no
      # existing DOM Children and it responds to #to_s
      def append_return_block(tag)
        return nil if current_arbre_element.children?

        if appendable_tag?(tag)
          current_arbre_element << Arbre::HTML::TextNode.from_string(tag.to_s)
        end
      end

      # Returns true if the object should be converted into a text node
      # and appended into the DOM.
      def appendable_tag?(tag)
        # Array.new.to_s prints out an empty array ("[]"). In
        # Arbre, we append the return value of blocks to the output, which
        # can cause empty arrays to show up within the output. To get
        # around this, we check if the object responds to #empty?
        if tag.respond_to?(:empty?) && tag.empty?
          false
        else
          !tag.is_a?(Arbre::Element) && tag.respond_to?(:to_s)
        end

      end
    end

  end
end
