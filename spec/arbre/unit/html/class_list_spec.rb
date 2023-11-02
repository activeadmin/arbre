# frozen_string_literal: true
require 'spec_helper'

describe Arbre::HTML::ClassList do

  describe ".build_from_string" do

    it "builds a new list from a string of classes" do
      list = described_class.build_from_string("first second")
      expect(list.size).to eq(2)

      expect(list).to match_array(%w{first second})
    end

  end

end
