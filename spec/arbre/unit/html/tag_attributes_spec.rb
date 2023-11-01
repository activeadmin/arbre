# frozen_string_literal: true
require 'spec_helper'

describe Arbre::HTML::Tag, "Attributes" do

  let(:tag){ described_class.new }

  describe "attributes" do

    before { tag.build id: "my_id" }

    it "has an attributes hash" do
      expect(tag.attributes).to eq({id: "my_id"})
    end

    describe "#to_s" do
      it "renders the attributes to html" do
        expect(tag.to_s).to eq "<tag id=\"my_id\"></tag>\n"
      end

      it "renders attributes that are empty but not nil" do
        tag.class_list # initializes an empty ClassList
        tag.set_attribute :foo, ''
        tag.set_attribute :bar, nil

        expect(tag.to_s).to eq "<tag id=\"my_id\" class=\"\" foo=\"\"></tag>\n"
      end

      context "with hyphenated attributes" do
        before { tag.build id: "my_id", "data-method" => "get", "data-remote" => true }

        it "renders the attributes to html" do
          expect(tag.to_s).to eq "<tag id=\"my_id\" data-method=\"get\" data-remote=\"true\"></tag>\n"
        end
      end

      context "when there is a nested attribute" do
        before { tag.build id: "my_id", data: { action: 'some_action' } }

        it "flattens the attributes when rendering to html" do
          expect(tag.to_s).to eq "<tag id=\"my_id\" data-action=\"some_action\"></tag>\n"
        end

        it "renders attributes that are empty but not nil" do
          tag.class_list # initializes an empty ClassList
          tag.set_attribute :foo, { bar: '' }
          tag.set_attribute :bar, { baz: nil }

          expect(tag.to_s).to eq "<tag id=\"my_id\" data-action=\"some_action\" class=\"\" foo-bar=\"\"></tag>\n"
        end
      end

      context "when there is a deeply nested attribute" do
        before { tag.build id: "my_id", foo: { bar: { bat: nil, baz: 'foozle' } } }

        it "flattens the attributes when rendering to html" do
          expect(tag.to_s).to eq "<tag id=\"my_id\" foo-bar-baz=\"foozle\"></tag>\n"
        end
      end

      context "when there are multiple nested attributes" do
        before { tag.build id: "my_id", foo: { bar: 'foozle1', bat: nil, baz: '' } }

        it "flattens the attributes when rendering to html" do
          expect(tag.to_s).to eq "<tag id=\"my_id\" foo-bar=\"foozle1\" foo-baz=\"\"></tag>\n"
        end
      end
    end

    it "gets an attribute value" do
      expect(tag.attr(:id)).to eq("my_id")
    end

    describe "#has_attribute?" do
      context "when the attribute exists" do
        it "returns true" do
          expect(tag.has_attribute?(:id)).to be(true)
        end
      end

      context "when the attribute does not exist" do
        it "returns false" do
          expect(tag.has_attribute?(:class)).to be(false)
        end
      end
    end

    it "removes an attribute" do
      expect(tag.attributes).to eq({id: "my_id"})
      expect(tag.remove_attribute(:id)).to eq("my_id")
      expect(tag.attributes).to eq({})
    end
  end

  describe "rendering attributes" do
    it "escapes attribute values" do
      tag.set_attribute(:class, '">bad things!')
      expect(tag.to_s).to eq "<tag class=\"&quot;&gt;bad things!\"></tag>\n"
    end

    it "escapes attribute names" do
      tag.set_attribute(">bad", "things")
      expect(tag.to_s).to eq "<tag &gt;bad=\"things\"></tag>\n"
    end
  end
end
