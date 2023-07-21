# frozen_string_literal: true
require 'spec_helper'

describe Arbre::HTML::Tag, "Attributes" do

  let(:tag){ Arbre::HTML::Tag.new }

  describe "attributes" do

    before { tag.build id: "my_id" }

    it "should have an attributes hash" do
      expect(tag.attributes).to eq({id: "my_id"})
    end

    describe "#to_s" do
      it "should render the attributes to html" do
        expect(tag.to_s).to eq "<tag id=\"my_id\"></tag>\n"
      end

      it "should still render attributes that are empty" do
        tag.class_list # initializes an empty ClassList
        tag.set_attribute :foo, ''
        tag.set_attribute :bar, nil

        expect(tag.to_s).to eq "<tag id=\"my_id\" class=\"\" foo=\"\" bar></tag>\n"
      end

      context "with hyphenated attributes" do
        before { tag.build id: "my_id", "data-method" => "get", "data-remote" => true }

        it "should render the attributes to html" do
          expect(tag.to_s).to eq "<tag id=\"my_id\" data-method=\"get\" data-remote=\"true\"></tag>\n"
        end
      end

      context "when there is a nested attribute" do
        before { tag.build id: "my_id", data: { action: 'some_action' } }

        it "should flatten the attributes when rendering to html" do
          expect(tag.to_s).to eq "<tag id=\"my_id\" data-action=\"some_action\"></tag>\n"
        end

        it "should still render attributes that are empty" do
          tag.class_list # initializes an empty ClassList
          tag.set_attribute :foo, { bar: '' }
          tag.set_attribute :bar, { baz: nil }

          expect(tag.to_s).to eq "<tag id=\"my_id\" data-action=\"some_action\" class=\"\" foo-bar=\"\" bar-baz></tag>\n"
        end
      end

      context "when there is a deeply nested attribute" do
        before { tag.build id: "my_id", foo: { bar: { baz: 'foozle' } } }

        it "should flatten the attributes when rendering to html" do
          expect(tag.to_s).to eq "<tag id=\"my_id\" foo-bar-baz=\"foozle\"></tag>\n"
        end
      end

      context "when there are multiple nested attributes" do
        before { tag.build id: "my_id", foo: { bar: 'foozle1', baz: 'foozle2' } }

        it "should flatten the attributes when rendering to html" do
          expect(tag.to_s).to eq "<tag id=\"my_id\" foo-bar=\"foozle1\" foo-baz=\"foozle2\"></tag>\n"
        end
      end
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
