# frozen_string_literal: true
module Arbre
  module HTML

    class Attributes < Hash

      def to_s
        map do |name, value|
          next if value_empty?(value)
          "#{html_escape(name)}=\"#{html_escape(value)}\""
        end.compact.join ' '
      end

      def any?
        super{ |k,v| !value_empty?(v) }
      end

      protected

      def value_empty?(value)
        value.respond_to?(:empty?) ? value.empty? : !value
      end

      def html_escape(s)
        ERB::Util.html_escape(s)
      end
    end

  end
end
