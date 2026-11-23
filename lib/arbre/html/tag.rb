# frozen_string_literal: true
require 'erb'

module Arbre
  module HTML

    class Tag < Element
      attr_reader :attributes

      # See: https://html.spec.whatwg.org/multipage/syntax.html#void-elements
      SELF_CLOSING_ELEMENTS = [ :area, :base, :br, :col, :embed, :hr, :img, :input, :keygen, :link,
                            :menuitem, :meta, :param, :source, :track, :wbr ]

      def initialize(arbre_context = Arbre::Context.new)
        super
        @attributes = Attributes.new
      end

      def build(*args)
        super
        original_hooks = arbre_render_flags.nobits?(Element::Rendering::CUSTOM_TAG_BUILD)
        attributes =
          if !original_hooks
            extract_arguments(args)
          elsif args.last.is_a?(Hash)
            args.pop
          end
        self.content = args.first if args.first
        return if original_hooks && attributes.nil?

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
        buffer = Element::Rendering.new_buffer
        arbre_write_tag_or_fallback(buffer)
        buffer.html_safe
      end

      def arbre_write_to(buffer, level, flags = arbre_render_flags)
        if flags.anybits?(Element::Rendering::CUSTOM_TO_S | FALLBACK_FLAGS)
          Element::Rendering.append(buffer, to_s)
        else
          arbre_write_tag(buffer, level, flags)
        end
      end

      private

      def opening_tag
        "<#{tag_name}#{attributes_html}>"
      end

      def closing_tag
        "</#{tag_name}>"
      end

      INDENT_SIZE = 2
      SPACES = Array.new(32) { |level| (' ' * level * INDENT_SIZE).freeze }.freeze

      # Overrides of these hooks render through the original indent(opening_tag, content, closing_tag).
      FALLBACK_FLAGS = Element::Rendering::CUSTOM_INDENT | Element::Rendering::CUSTOM_CONTENT |
                       Element::Rendering::CUSTOM_CHILDREN | Element::Rendering::CUSTOM_PREDICATES

      def indent(open_tag, child_content, close_tag)
        spaces = ' ' * indent_level * INDENT_SIZE

        html = +""

        if no_child? || child_is_text?
          if self_closing_tag?
            html << spaces << open_tag.sub( />$/, '/>' )
          else
            # one line
            html << spaces << open_tag << child_content << close_tag
          end
        else
          # multiple lines
          html << spaces << open_tag << "\n"
          html << child_content # the child takes care of its own spaces
          html << spaces << close_tag
        end

        html << "\n"
      end

      def arbre_write_tag_or_fallback(buffer)
        flags = arbre_render_flags
        if flags.anybits?(FALLBACK_FLAGS)
          buffer << indent(opening_tag, content, closing_tag)
        else
          arbre_write_tag(buffer, indent_level, flags)
        end
      end

      # Writes what indent(opening_tag, content, closing_tag) returns. The layout is
      # chosen before the children render and checked again after, as indent does.
      def arbre_write_tag(buffer, level, flags)
        spaces = SPACES[level] || ' ' * level * INDENT_SIZE
        open_tag = opening_tag if flags.anybits?(Element::Rendering::CUSTOM_OPEN)
        one_line = arbre_one_line?
        void = one_line && self_closing_tag?

        start = buffer.bytesize
        buffer.force_encoding(Encoding::UTF_8) if start == 0 # Tag#to_s starts from a UTF-8 string
        buffer << spaces
        if open_tag
          buffer << open_tag
        else
          arbre_write_open_tag(buffer, void)
        end
        open_end = buffer.bytesize
        buffer << "\n" unless one_line

        arbre_write_children(buffer, level)
        close_tag = flags.anybits?(Element::Rendering::CUSTOM_CLOSE) ? closing_tag : nil

        if one_line != arbre_one_line?
          return arbre_relayout(buffer, start, spaces, open_end, one_line, void, open_tag.nil?, close_tag)
        end

        if void
          if open_tag
            buffer.bytesplice(start, buffer.bytesize - start, spaces)
            buffer << open_tag.sub(/>$/, '/>')
          else
            buffer.bytesplice(open_end, buffer.bytesize - open_end, "")
          end
        else
          buffer << spaces unless one_line
          close_tag ? buffer << close_tag : arbre_write_close_tag(buffer)
        end
        buffer << "\n"
      end

      # Children changed the layout while rendering: rebuild this tag from its parts.
      def arbre_relayout(buffer, start, spaces, open_end, one_line, void, direct_open, close_tag)
        open_tag = buffer.byteslice(start + spaces.bytesize, open_end - start - spaces.bytesize)
        open_tag = "#{open_tag.delete_suffix('/>')}>" if void && direct_open
        child_content = buffer.byteslice(open_end + (one_line ? 0 : 1), buffer.bytesize)
        buffer.bytesplice(start, buffer.bytesize - start, "")
        close_tag ||= closing_tag
        buffer << indent(open_tag, child_content, close_tag)
      end

      def arbre_one_line?
        @children.empty? || (@children.size == 1 && @children.first.is_a?(TextNode))
      end

      def arbre_write_open_tag(buffer, void)
        buffer << "<"
        Element::Rendering.append(buffer, tag_name)
        unless @attributes.empty?
          buffer << " "
          @attributes.arbre_write_to(buffer)
        end
        buffer << (void ? "/>" : ">")
      end

      def arbre_write_close_tag(buffer)
        buffer << "</"
        Element::Rendering.append(buffer, tag_name)
        buffer << ">"
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
          record.class.name.underscore.tr("/", "_")
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

      # Tag#build skips the empty hash extract_arguments returns, and the
      # set_for_attribute(nil) call, only while both are these originals.
      ORIGINAL_BUILD_HOOKS = [instance_method(:extract_arguments), instance_method(:set_for_attribute)].freeze
    end

  end
end
