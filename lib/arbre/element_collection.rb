# frozen_string_literal: true
module Arbre

  # Stores a collection of Element objects
  class ElementCollection < Array
    def +(other)
      self.class.new(super)
    end

    def -(other)
      self.class.new(super)
    end

    def &(other)
      self.class.new(super)
    end

    def to_s
      buffer = String.new(encoding: Encoding::US_ASCII) # like [].join
      each do |element|
        if Element === element
          element.arbre_write_to(buffer, element.indent_level)
        else
          Element::Rendering.append(buffer, element.to_s)
        end
      end
      buffer.html_safe
    end

    # True when to_s is not ElementCollection#to_s, so renderers must call it.
    def arbre_custom_to_s?
      @arbre_custom_to_s || !instance_of?(ElementCollection)
    end

    def extend(*)
      super.tap { @arbre_custom_to_s = true }
    end

    private

    def singleton_method_added(name)
      super
      @arbre_custom_to_s = true if name == :to_s
    end
  end

end
