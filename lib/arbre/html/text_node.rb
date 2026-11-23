# frozen_string_literal: true
require 'erb'

module Arbre
  module HTML

    class TextNode < Element
      builder_method :text_node

      # Builds a text node from a string
      def self.from_string(string)
        node = new
        node.build(string)
        node
      end

      # Skips the Context and child collection that Element#initialize builds:
      # a text node made by from_string never uses them.
      def initialize(arbre_context = nil)
        @arbre_context = arbre_context
        @parent = nil
      end

      def arbre_context
        @arbre_context ||= Arbre::Context.new
      end

      def children
        @children ||= ElementCollection.new
      end

      def children?
        children.any?
      end

      def remove_child(child)
        child.parent = nil if child.respond_to?(:parent=)
        children.delete(child)
      end

      def add_child(*args)
        raise "TextNodes do not have children"
      end

      def build(string)
        @content = string
      end

      def class_list
        []
      end

      def tag_name
        nil
      end

      def to_s
        ERB::Util.html_escape(@content.to_s)
      end

      def arbre_write_to(buffer, _level, flags = arbre_render_flags)
        if flags.anybits?(Element::Rendering::CUSTOM_TO_S)
          Element::Rendering.append(buffer, to_s)
        else
          Element::Rendering.append_escaped(buffer, @content)
        end
      end

      private

      def clear_children!
        children.clear
      end
    end

  end
end
