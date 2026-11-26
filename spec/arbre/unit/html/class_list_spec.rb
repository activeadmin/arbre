# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Arbre::HTML::ClassList do

  describe ".build_from_string" do

    it "builds a new list from a string of classes" do
      list = described_class.build_from_string("first second")
      expect(list.size).to eq(2)

      expect(list).to match_array(%w{first second})
    end

  end

  describe "#add" do
    it "adds each class from a string of classes" do
      list = described_class.new
      list << "first second"
      list.add "second third"
      expect(list.to_s).to eq("first second third")
    end
  end

end
