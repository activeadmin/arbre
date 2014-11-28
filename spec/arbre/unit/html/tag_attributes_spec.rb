require 'spec_helper'

describe Arbre::HTML::Tag, "Attributes" do

  let(:tag){ Arbre::HTML::Tag.new }

  describe "attributes" do

    before { tag.build id: "my_id" }

    it "should have an attributes hash" do
      expect(tag.attributes).to eq({id: "my_id"})
    end

    it "should render the attributes to html" do
      expect(tag.to_s).to eq "<tag id=\"my_id\"></tag>\n"
    end

    it "shouldn't render attributes that are empty" do
      tag.class_list # initializes an empty ClassList
      tag.set_attribute :foo, ''
      tag.set_attribute :bar, nil

      expect(tag.to_s).to eq "<tag id=\"my_id\"></tag>\n"
    end

    it "should get an attribute value" do
      expect(tag.attr(:id)).to eq("my_id")
    end

    describe "#has_attribute?" do
      context "when the attribute exists" do
        it "should return true" do
          expect(tag.has_attribute?(:id)).to eq(true)
        end
      end

      context "when the attribute does not exist" do
        it "should return false" do
          expect(tag.has_attribute?(:class)).to eq(false)
        end
      end
    end

    it "should remove an attribute" do
      expect(tag.attributes).to eq({id: "my_id"})
      expect(tag.remove_attribute(:id)).to eq("my_id")
      expect(tag.attributes).to eq({})
    end
  end

  describe "rendering attributes" do
    it "should html safe the attribute values" do
      tag.set_attribute(:class, '">bad things!')
      expect(tag.to_s).to eq "<tag class=\"&quot;&gt;bad things!\"></tag>\n"
    end
    it "should should escape the attribute names" do
      tag.set_attribute(">bad", "things")
      expect(tag.to_s).to eq "<tag &gt;bad=\"things\"></tag>\n"
    end
  end
end
