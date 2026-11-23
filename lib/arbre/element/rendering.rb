# frozen_string_literal: true
module Arbre
  class Element
    # Renders a tree into one shared buffer. An object whose class or singleton
    # class overrides one of RENDER_METHODS renders through that override instead.
    module Rendering
      CUSTOM_TO_S = 1
      CUSTOM_CONTENT = 2
      CUSTOM_CHILDREN = 4
      CONTEXT_LEVEL = 8
      CUSTOM_LEVEL = 16
      CUSTOM_INDENT = 32
      CUSTOM_OPEN = 64
      CUSTOM_CLOSE = 128
      CUSTOM_PREDICATES = 256
      CUSTOM_BUILDER = 512
      CUSTOM_TAG_BUILD = 1024
      ORIGINAL_BUILD_CHAIN = 2048
      PLAIN_TAG = 4096

      RENDER_METHODS = [
        :to_s, :content, :children, :indent_level, :indent, :opening_tag, :closing_tag,
        :attributes_html, :attributes, :no_child?, :child_is_text?, :self_closing_tag?,
        :insert_tag, :build_tag, :extract_arguments, :set_for_attribute, :build, :arbre_build_arguments,
        :arbre_write_to, :arbre_write_tag
      ].to_h { |name| [name, true] }.freeze

      ORIGINAL_BUILDER_METHODS = [
        BuilderMethods.instance_method(:insert_tag), BuilderMethods.instance_method(:build_tag)
      ].freeze

      # Redefining or adding to BuilderMethods must also invalidate cached flags.
      module HookInvalidation
        def include(*) = super.tap { Rendering.bump_generation! }
        def prepend(*) = super.tap { Rendering.bump_generation! }

        private

        def method_added(name) = super.tap { Rendering.bump_generation! if RENDER_METHODS[name] }
        def method_removed(name) = super.tap { Rendering.bump_generation! if RENDER_METHODS[name] }
        def method_undefined(name) = super.tap { Rendering.bump_generation! if RENDER_METHODS[name] }
      end
      BuilderMethods.extend(HookInvalidation)

      UNSAFE_HTML = /[&<>"']/

      # One mutable slot, read on every render-flag lookup.
      GENERATION = [0] # rubocop:disable Style/MutableConstant

      class << self
        def generation
          GENERATION[0]
        end

        # Invalidates every cached set of render flags.
        def bump_generation!
          GENERATION[0] += 1
        end

        def new_buffer
          +""
        end

        # Appends a to_s result the way Array#join would: nil adds nothing, other
        # objects add their string form, and the first piece sets the encoding.
        def append(buffer, value)
          case value
          when String then concat(buffer, value)
          when nil then buffer
          else concat(buffer, [value].join)
          end
        end

        # Appends ERB::Util.html_escape(value) without allocating when nothing
        # needs escaping.
        def append_escaped(buffer, value)
          string =
            case value
            when String then value
            when Symbol then value.name
            else value.to_s
            end

          if string.html_safe? ||
             (string.encoding.ascii_compatible? && string.valid_encoding? && !string.match?(UNSAFE_HTML))
            concat(buffer, string)
          else
            concat(buffer, ERB::Util.unwrapped_html_escape(string))
          end
        end

        # Symbol names always have a valid encoding, so only the characters matter.
        def append_escaped_name(buffer, name)
          string = name.name
          if string.encoding.ascii_compatible? && !string.match?(UNSAFE_HTML)
            buffer << string
          else
            buffer << ERB::Util.unwrapped_html_escape(string)
          end
        end

        def concat(buffer, string)
          buffer.force_encoding(string.encoding) if buffer.empty?
          buffer << string
        end
      end

      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        def arbre_default_tag_name
          class_name = name
          cached = @arbre_default_tag_name
          return cached[1] if cached && cached[0] == class_name

          tag_name = class_name.demodulize.downcase.freeze
          @arbre_default_tag_name = [class_name, tag_name].freeze unless frozen?
          tag_name
        end

        def arbre_render_flags
          generation = GENERATION[0]
          return @arbre_render_flags if @arbre_render_generation == generation

          flags = compute_arbre_render_flags
          unless frozen?
            @arbre_render_flags = flags
            @arbre_render_generation = generation
          end
          flags
        end

        def include(*)
          super.tap { Rendering.bump_generation! }
        end

        def prepend(*)
          super.tap { Rendering.bump_generation! }
        end

        private

        def method_added(name)
          super
          Rendering.bump_generation! if RENDER_METHODS[name]
        end

        def method_removed(name)
          super
          Rendering.bump_generation! if RENDER_METHODS[name]
        end

        def method_undefined(name)
          super
          Rendering.bump_generation! if RENDER_METHODS[name]
        end

        def compute_arbre_render_flags
          flags = 0
          flags |= CUSTOM_TO_S unless arbre_owner?(:to_s, Element, HTML::Tag, HTML::TextNode, HTML::Document)
          flags |= CUSTOM_CONTENT unless arbre_owner?(:content, Element)
          flags |= CUSTOM_CHILDREN unless arbre_owner?(:children, Element, HTML::TextNode)
          flags |= CUSTOM_BUILDER unless instance_method(:insert_tag) == ORIGINAL_BUILDER_METHODS[0] &&
                                         instance_method(:build_tag) == ORIGINAL_BUILDER_METHODS[1]

          level_owner = instance_method(:indent_level).owner
          if level_owner == Context
            flags |= CONTEXT_LEVEL
          elsif level_owner != Element
            flags |= CUSTOM_LEVEL
          end

          if self <= HTML::Tag
            flags |= CUSTOM_INDENT unless arbre_owner?(:indent, HTML::Tag)
            flags |= CUSTOM_OPEN unless arbre_owner?(:opening_tag, HTML::Tag) &&
                                        arbre_owner?(:attributes_html, HTML::Tag) &&
                                        arbre_owner?(:attributes, HTML::Tag)
            flags |= CUSTOM_CLOSE unless arbre_owner?(:closing_tag, HTML::Tag)
            flags |= ORIGINAL_BUILD_CHAIN if arbre_original_build_chain?
            flags |= CUSTOM_TAG_BUILD unless instance_method(:extract_arguments) == HTML::Tag::ORIGINAL_BUILD_HOOKS[0] &&
                                             instance_method(:set_for_attribute) == HTML::Tag::ORIGINAL_BUILD_HOOKS[1]
            flags |= CUSTOM_PREDICATES unless arbre_owner?(:no_child?, HTML::Tag) &&
                                              arbre_owner?(:child_is_text?, HTML::Tag) &&
                                              arbre_owner?(:self_closing_tag?, HTML::Tag)
            if flags.nobits?(CUSTOM_TO_S | HTML::Tag::FALLBACK_FLAGS) &&
               arbre_owner?(:arbre_write_to, HTML::Tag) && arbre_owner?(:arbre_write_tag, HTML::Tag)
              flags |= PLAIN_TAG
            end
          end
          flags
        end

        # build is Tag#build, and the build its super reaches is Element#build.
        def arbre_original_build_chain?
          return false unless instance_method(:build) == HTML::Tag::ORIGINAL_BUILDS[0] &&
                              arbre_owner?(:arbre_build_arguments, HTML::Tag)

          after_tag = ancestors.drop(ancestors.index(HTML::Tag) + 1)
          next_build = after_tag.find do |mod|
            mod.instance_methods(false).include?(:build) || mod.private_instance_methods(false).include?(:build)
          end
          next_build == Element && Element.instance_method(:build) == HTML::Tag::ORIGINAL_BUILDS[1]
        end

        def arbre_owner?(method_name, *owners)
          owners.include?(instance_method(method_name).owner)
        end
      end

      def extend(*)
        super.tap do
          @arbre_singleton_render = true
          Rendering.bump_generation!
        end
      end

      # Writes this element's HTML, as to_s would return it, into buffer.
      # level is the value indent_level returns for this element.
      def arbre_write_to(buffer, level, flags = arbre_render_flags)
        if flags & (CUSTOM_TO_S | CUSTOM_CONTENT | CUSTOM_CHILDREN) != 0
          Rendering.append(buffer, to_s)
        else
          arbre_write_children(buffer, level)
        end
      end

      def arbre_render_flags
        (@arbre_singleton_render ? singleton_class : self.class).arbre_render_flags
      end

      private

      def singleton_method_added(name)
        super
        return unless RENDER_METHODS[name]

        @arbre_singleton_render = true
        Rendering.bump_generation!
      end

      def arbre_write_children(buffer, level)
        return Rendering.append(buffer, @children.to_s) if @children.arbre_custom_to_s?

        @children.each do |child|
          if Element === child
            flags = child.arbre_render_flags
            child_level =
              if flags & CUSTOM_LEVEL != 0 || !child.parent.equal?(self)
                child.indent_level
              elsif flags & CONTEXT_LEVEL != 0
                level
              else
                level + 1
              end
            if flags & PLAIN_TAG != 0
              child.arbre_write_tag(buffer, child_level, flags)
            else
              child.arbre_write_to(buffer, child_level, flags)
            end
          else
            Rendering.append(buffer, child.to_s)
          end
        end
        buffer
      end
    end
  end
end
