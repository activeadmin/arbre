require 'active_model'

class MockPerson
  extend ActiveModel::Naming

  attr_accessor :name

  def persisted?
    false
  end

  def to_key
    []
  end
end
