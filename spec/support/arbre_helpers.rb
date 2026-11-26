# frozen_string_literal: true

module ArbreHelpers
  # Builds an Arbre context using the example's `assigns` and `helpers`.
  def arbre(&block)
    Arbre::Context.new assigns, helpers, &block
  end
end
