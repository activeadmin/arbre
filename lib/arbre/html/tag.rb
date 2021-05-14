# frozen_string_literal: true
require 'erb'

module Arbre
  module HTML

    class Tag < Element
      attr_reader :attributes

      # See: http://www.w3.org/html/wg/drafts/html/master/syntax.html#void-elements
      SELF_CLOSING_ELEMENTS = [ :area, :base, :br, :col, :embed, :hr, :img, :input, :keygen, :link,
                            :menuitem, :meta, :param, :source, :track, :wbr ]

      def initialize(*)
        super
        @attributes = Attributes.new
      end

      def build(*args)
        super
        attributes = extract_arguments(args)
        self.content = args.first if args.first

        for_value = attributes[:for]
        unless for_value.is_a?(String) || for_value.is_a?(Symbol)
          set_for_attribute(attributes.delete(:for))
        end

        attributes.each do |key, value|
          set_attribute(key, value)
        end
      end

      def extract_arguments(args)
        if args.last.is_a?(Hash)
          args.pop
        else
          {}
        end
      end

      def set_attribute(name, value)
        @attributes[name.to_sym] = value
      end

      def get_attribute(name)
        @attributes[name.to_sym]
      end
      alias :attr :get_attribute

      def has_attribute?(name)
        @attributes.has_key?(name.to_sym)
      end

      def remove_attribute(name)
        @attributes.delete(name.to_sym)
      end

      def id
        get_attribute(:id)
      end

      # Generates and id for the object if it doesn't exist already
      def id!
        return id if id
        self.id = object_id.to_s
        id
      end

      def id=(id)
        set_attribute(:id, id)
      end

      def add_class(class_names)
        class_list.add class_names
      end

      def remove_class(class_names)
        class_list.delete(class_names)
      end

      # Returns a string of classes
      def class_names
        class_list.to_s
      end

      def class_list
        list = get_attribute(:class)

        case list
        when ClassList
          list
        when String
          set_attribute(:class, ClassList.build_from_string(list))
        else
          set_attribute(:class, ClassList.new)
        end
      end

      def to_s
        indent(opening_tag, content, closing_tag).html_safe
      end

      private

      def opening_tag
        "<#{tag_name}#{attributes_html}>"
      end

      def closing_tag
        "</#{tag_name}>"
      end

      INDENT_SIZE = 2

      def indent(open_tag, child_content, close_tag)
        spaces = ' ' * indent_level * INDENT_SIZE

        html = ""

        if no_child? || child_is_text?
          if self_closing_tag?
            html += spaces + open_tag.sub( />$/, '/>' )
          else
            # one line
            html += spaces + open_tag + child_content + close_tag
          end
        else
          # multiple lines
          html += spaces + open_tag + "\n"
          html += child_content # the child takes care of its own spaces
          html += spaces + close_tag
        end

        html += "\n"

        html
      end

      def self_closing_tag?
        SELF_CLOSING_ELEMENTS.include?(tag_name.to_sym)
      end

      def no_child?
        children.empty?
      end

      def child_is_text?
        children.size == 1 && children.first.is_a?(TextNode)
      end

      def attributes_html
        " #{attributes}" if attributes.any?
      end

      def set_for_attribute(record)
        return unless record
        # set_attribute :id, ActionController::RecordIdentifier.dom_id(record, default_id_for_prefix)
        # add_class ActionController::RecordIdentifier.dom_class(record)
        set_attribute :id, dom_id_for(record)
        add_class dom_class_name_for(record)
      end

      def dom_class_name_for(record)
        if record.class.respond_to?(:model_name)
          record.class.model_name.singular
        else
          record.class.name.underscore.gsub("/", "_")
        end
      end

      def dom_id_for(record)
        id = if record.respond_to?(:to_key)
               record.to_key
             elsif record.respond_to?(:id)
               record.id
             else
               record.object_id
             end

        [default_id_for_prefix, dom_class_name_for(record), id].compact.join("_")
      end

      def default_id_for_prefix
        nil
      end

    end

  end
end
