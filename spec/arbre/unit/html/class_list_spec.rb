require 'spec_helper'

describe Arbre::HTML::ClassList do

  describe ".build_from_string" do

    it "should build a new list from a string of classes" do
      list = Arbre::HTML::ClassList.build_from_string("first second")
      expect(list.size).to eq(2)

      expect(list.to_a.sort).to eq(%w{first second})
    end

  end

end
