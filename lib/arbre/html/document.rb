# frozen_string_literal: true
module Arbre
  module HTML

    class Document < Tag
      def build(*args)
        super
        build_head
        build_body
      end

      def document
        self
      end

      def tag_name
        'html'
      end

      def doctype
        '<!DOCTYPE html>'.html_safe
      end

      def to_s
        buffer = Element::Rendering.new_buffer
        Element::Rendering.append(buffer, doctype)
        arbre_write_tag_or_fallback(buffer)
        buffer.html_safe
      end

      def arbre_write_to(buffer, level, flags = arbre_render_flags)
        return Element::Rendering.append(buffer, to_s) if flags.anybits?(Element::Rendering::CUSTOM_TO_S | FALLBACK_FLAGS)

        Element::Rendering.append(buffer, doctype)
        arbre_write_tag(buffer, level, flags)
      end

      protected

      def build_head
        @head = head do
          meta "http-equiv": "Content-type", content: "text/html; charset=utf-8"
        end
      end

      def build_body
        @body = body
      end
    end

  end
end
