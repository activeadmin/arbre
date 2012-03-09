require 'arbre/element'

module Arbre
  class Context < Element

    def initialize(assigns = {}, helpers = nil, &block)
      @_assigns = assigns || {}
      @_assigns.symbolize_keys!
      @_helpers = helpers
      @_current_arbre_element_buffer = [self]

      super(self)
      instance_eval &block if block_given?
    end

    def arbre_context
      self
    end

    def assigns
      @_assigns
    end

    def helpers
      @_helpers
    end

    def indent_level
      # A context does not increment the indent_level
      super - 1
    end

    def bytesize
      cached_html.bytesize
    end
    alias :length :bytesize

    def respond_to?(method)
      super || cached_html.respond_to?(method)
    end

    # Webservers treat Arbre::Context as a string. We override
    # method_missing to delegate to the string representation
    # of the html.
    def method_missing(method, *args, &block)
      if cached_html.respond_to? method
        cached_html.send method, *args, &block
      else
        super
      end
    end

    def current_arbre_element
      @_current_arbre_element_buffer.last
    end

    def with_current_arbre_element(tag)
      raise ArgumentError, "Can't be in the context of nil. #{@_current_arbre_element_buffer.inspect}" unless tag
      @_current_arbre_element_buffer.push tag
      yield
      @_current_arbre_element_buffer.pop
    end
    alias_method :within, :with_current_arbre_element

    private


    # Caches the rendered HTML so that we don't re-render just to
    # get the content lenght or to delegate a method to the HTML
    def cached_html
      if defined?(@cached_html)
        @cached_html
      else
        html = to_s
        @cached_html = html if html.length > 0
        html
      end
    end

  end
end
