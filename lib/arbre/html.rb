module Arbre
  module HTML
    autoload :Attributes, 'arbre/html/attributes'
    autoload :ClassList, 'arbre/html/class_list'
    autoload :Tag, 'arbre/html/tag'
    autoload :TextNode, 'arbre/html/text_node'
    autoload :Document, 'arbre/html/document'
    autoload :Elements, 'arbre/html/elements'

    include Elements
  end
end
