module Arbre
  class Element
    class Proxy < BasicObject
      undef_method :==
      undef_method :equal?

      def initialize(element)
        @element = element
      end

      def respond_to?(method, include_all = false)
        if method.to_s == 'to_ary'
          false
        else
          super || @element.respond_to?(method, include_all)
        end
      end

      def method_missing(method, *args, &block)
        if method.to_s == 'to_ary'
          super
        else
          @element.__send__ method, *args, &block
        end
      end
    end
  end
end
