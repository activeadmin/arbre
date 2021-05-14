# frozen_string_literal: true
require 'set'

module Arbre
  module HTML

    # Holds a set of classes
    class ClassList < Set

      def self.build_from_string(class_names)
        new.add(class_names)
      end

      def add(class_names)
        class_names.to_s.split(" ").each do |class_name|
          super(class_name)
        end
        self
      end
      alias :<< :add

      def to_s
        to_a.join(" ")
      end

    end

  end
end
