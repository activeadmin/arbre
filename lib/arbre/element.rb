require 'arbre/element/builder_methods'
require 'arbre/element/proxy'
require 'arbre/element_collection'

module Arbre

  class Element
    include BuilderMethods

    attr_accessor :parent
    attr_reader :children, :arbre_context

    def initialize(arbre_context = Arbre::Context.new)
      @arbre_context = arbre_context
      @children = ElementCollection.new
    end

    def assigns
      arbre_context.assigns
    end

    def helpers
      arbre_context.helpers
    end

    def tag_name
      @tag_name ||= self.class.name.demodulize.downcase
    end

    def build(*args, &block)
      # Render the block passing ourselves in
      append_return_block(block.call(self)) if block
    end

    def add_child(child)
      return unless child

      if child.is_a?(Array)
        child.each{|item| add_child(item) }
        return @children
      end

      # If its not an element, wrap it in a TextNode
      unless child.is_a?(Element)
        child = Arbre::HTML::TextNode.from_string(child)
      end

      if child.respond_to?(:parent)
        # Remove the child
        child.parent.remove_child(child) if child.parent && child.parent != self
        # Set ourselves as the parent
        child.parent = self
      end

      @children << child
    end

    def remove_child(child)
      child.parent = nil if child.respond_to?(:parent=)
      @children.delete(child)
    end

    def <<(child)
      add_child(child)
    end

    def children?
      @children.any?
    end

    def parent=(parent)
      @parent = parent
    end

    def parent?
      !@parent.nil?
    end

    def ancestors
      if parent?
        [parent] + parent.ancestors
      else
        []
      end
    end

    # TODO: Shouldn't grab whole tree
    def find_first_ancestor(type)
      ancestors.find{|a| a.is_a?(type) }
    end

    def content=(contents)
      clear_children!
      add_child(contents)
    end

    def get_elements_by_tag_name(tag_name)
      elements = ElementCollection.new
      children.each do |child|
        elements << child if child.tag_name == tag_name
        elements.concat(child.get_elements_by_tag_name(tag_name))
      end
      elements
    end
    alias_method :find_by_tag, :get_elements_by_tag_name

    def get_elements_by_class_name(class_name)
      elements = ElementCollection.new
      children.each do |child|
        elements << child if child.class_list.include?(class_name)
        elements.concat(child.get_elements_by_class_name(class_name))
      end
      elements
    end
    alias_method :find_by_class, :get_elements_by_class_name

    def content
      children.to_s
    end

    def html_safe
      to_s
    end

    def indent_level
      parent? ? parent.indent_level + 1 : 0
    end

    def each(&block)
      [to_s].each(&block)
    end

    def inspect
      to_s
    end

    def to_str
      to_s
    end

    def to_s
      content
    end

    def +(element)
      case element
      when Element, ElementCollection
      else
        element = Arbre::HTML::TextNode.from_string(element)
      end
      to_ary + element
    end

    def to_ary
      ElementCollection.new [Proxy.new(self)]
    end
    alias_method :to_a, :to_ary

    private

    # Resets the Elements children
    def clear_children!
      @children.clear
    end

    # Implements the method lookup chain. When you call a method that
    # doesn't exist, we:
    #
    #  1. Try to call the method on the current DOM context
    #  2. Return an assigned variable of the same name
    #  3. Call the method on the helper object
    #  4. Call super
    #
    def method_missing(name, *args, &block)
      if current_arbre_element.respond_to?(name)
        current_arbre_element.send name, *args, &block
      elsif assigns && assigns.has_key?(name)
        assigns[name]
      elsif helpers.respond_to?(name)
        helpers.send(name, *args, &block)
      else
        super
      end
    end

  end
end
