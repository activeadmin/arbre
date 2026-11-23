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
        start = buffer.bytesize
        keys_checked = false
        first = true
        each_pair do |name, value|
          # Values written so far are converted again if the keys turn out to
          # need to_s, so check every key before a nested hash or an arbitrary to_s.
          unless keys_checked || (Symbol === name && PLAIN_VALUES[value.class])
            keys = arbre_key_kinds(self, 0)
            if keys.anybits?(NON_SYMBOL_KEY) || keys.allbits?(NESTED_HASH | DASHED_KEY)
              buffer.bytesplice(start, buffer.bytesize - start, "")
              return buffer << to_s
            end
            keys_checked = true
          end

          if Hash === value
            first = arbre_write_pairs(buffer, value, name, first)
            next
          end
          next if value.nil?

          buffer << " " unless first
          first = false
          Element::Rendering.append_escaped_name(buffer, name)
          buffer << '="'
          Element::Rendering.append_escaped(buffer, value)
          buffer << '"'
        end
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

      PLAIN_VALUES = [String, Symbol, Integer, Float, TrueClass, FalseClass, NilClass].to_h { |klass| [klass, true] }.freeze
      private_constant :PLAIN_VALUES

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
