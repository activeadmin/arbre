# frozen_string_literal: true
module Arbre
  module HTML

    class Attributes < Hash
      def to_s
        flatten_hash.compact.map do |name, value|
          "#{html_escape(name)}=\"#{html_escape(value)}\""
        end.join ' '
      end

      # Writes to_s into buffer. Flattened names can collide when keys are not
      # Symbols, or when a nested hash sits beside a key with a dash.
      def arbre_write_to(buffer)
        keys = arbre_key_kinds(self, 0)
        return buffer << to_s if keys.anybits?(NON_SYMBOL_KEY) || keys.allbits?(NESTED_HASH | DASHED_KEY)

        arbre_write_pairs(buffer, self, nil, true)
        buffer
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

      private

      NON_SYMBOL_KEY = 1
      NESTED_HASH = 2
      DASHED_KEY = 4
      private_constant :NON_SYMBOL_KEY, :NESTED_HASH, :DASHED_KEY

      def arbre_key_kinds(hash, kinds)
        hash.each_pair do |name, value|
          if Symbol === name
            kinds |= DASHED_KEY if name.name.include?("-")
          else
            kinds |= NON_SYMBOL_KEY
          end
          kinds = arbre_key_kinds(value, kinds | NESTED_HASH) if Hash === value
        end
        kinds
      end

      # Returns whether nothing has been written yet, for the separator. prefix
      # is nil, the parent key, or an Array of keys below the first level.
      def arbre_write_pairs(buffer, hash, prefix, first)
        hash.each_pair do |name, value|
          if Hash === value
            nested_prefix =
              case prefix
              when nil then name
              when Symbol then [prefix, name]
              else prefix + [name]
              end
            first = arbre_write_pairs(buffer, value, nested_prefix, first)
            next
          end
          next if value.nil?

          buffer << " " unless first
          first = false
          if Symbol === prefix
            Element::Rendering.append_escaped_name(buffer, prefix)
            buffer << "-"
          else
            prefix&.each do |segment|
              Element::Rendering.append_escaped_name(buffer, segment)
              buffer << "-"
            end
          end
          Element::Rendering.append_escaped_name(buffer, name)
          buffer << '="'
          Element::Rendering.append_escaped(buffer, value)
          buffer << '"'
        end
        first
      end

      protected

      def html_escape(s)
        ERB::Util.html_escape(s)
      end
    end

  end
end
