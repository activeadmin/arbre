# frozen_string_literal: true
module Arbre
  module HTML

    class Attributes < Hash

      def to_s
        flatten_hash.map do |name, value|
          next if value_empty?(value)
          "#{html_escape(name)}=\"#{html_escape(value)}\""
        end.compact.join ' '
      end

      def any?
        super{ |k,v| !value_empty?(v) }
      end

      protected

      def flatten_hash(hash = self, old_path = [], accumulator = {})
        hash.each do |key, value|
          path = old_path + [key]
          if value.is_a? Hash
            flatten_hash(value, path, accumulator)
          else
            accumulator[path.join('-')] = value
          end
        end
        accumulator
      end

      def value_empty?(value)
        value.respond_to?(:empty?) ? value.empty? : !value
      end

      def html_escape(s)
        ERB::Util.html_escape(s)
      end
    end

  end
end
