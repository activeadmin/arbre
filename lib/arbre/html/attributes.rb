module Arbre
  module HTML

    class Attributes < Hash

      def to_s
        results = self.inject([]) do |out, (name, value)|
          out << %[#{html_escape(name)}="#{html_escape(value)}"]
        end

        results.join(' ')
      end

      protected

      def html_escape(s)
        ERB::Util.html_escape(s)
      end
    end

  end
end
