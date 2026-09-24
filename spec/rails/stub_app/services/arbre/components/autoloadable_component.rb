# frozen_string_literal: true
class Arbre::Components::AutoloadableComponent < Arbre::Component
  builder_method :autoloadable_component

  def build
    div "Autoloadable Component"
  end
end
