module Arbre
  module Rails
    module Forms

      class FormBuilderProxy < Arbre::Component
        attr_reader :form_builder

        # Since label and select are Arbre Elements already, we must
        # override it here instead of letting method_missing
        # deal with it
        def label(*args)
          proxy_call_to_form :label, *args
        end

        def select(*args)
          proxy_call_to_form :select, *args
        end

        def respond_to_missing?(method, include_all)
          if form_builder && form_builder.respond_to?(method, include_all)
            true
          else
            super
          end
        end

        private

        def proxy_call_to_form(method, *args, &block)
          text_node form_builder.send(method, *args, &block)
        end

        def method_missing(method, *args, &block)
          if form_builder && form_builder.respond_to?(method)
            proxy_call_to_form(method, *args, &block)
          else
            super
          end
        end

      end

      class FormForProxy < FormBuilderProxy
        builder_method :form_for

        def build(resource, form_options = {}, &block)
          form_string = helpers.form_for(resource, form_options) do |f|
            @form_builder = f
          end

          @opening_tag, @closing_tag = split_string_on(form_string, "</form>")
          super(&block)
        end

        def fields_for(*args, &block)
          insert_tag FieldsForProxy, form_builder, *args, &block
        end

        def split_string_on(string, match)
          return "" unless string && match
          part_1 = string.split(Regexp.new("#{match}\\z")).first
          [part_1, match]
        end

        def opening_tag
          @opening_tag || ""
        end

        def closing_tag
          @closing_tag || ""
        end

      end

      class FieldsForProxy < FormBuilderProxy

        def build(form_builder, *args, &block)
          form_builder.fields_for(*args) do |f|
            @form_builder = f
          end

          super(&block)
        end

        def to_s
          children.to_s
        end

      end

    end
  end
end


