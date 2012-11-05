module Arbre
  module HTML
    class Attributes < Hash
      def []=(key, value)
        if (data_key = key.to_s[/^data\-(.+)$/, 1])
          self[:data] = fetch(:data, {}).merge(:"#{data_key}" => value)
        else
          super(key, value)
        end
      end

      def to_s
        attrs = self.inject({:data => {}}) do |h, (key, value)|
          h[key] = value; h
        end

        attrs.delete(:data).each do |key, value|
          attrs["data-#{key}"] = value
        end

        attrs.collect do |name, value|
          %(#{ERB::Util.h(name)}="#{ERB::Util.h(value)}")
        end.join(" ")
      end
    end
  end
end
