# frozen_string_literal: true
require 'spec_helper'

describe Arbre::HTML::Tag do

  let(:tag){ described_class.new }

  describe "building a new tag" do
    before { tag.build "Hello World", id: "my_id" }

    it "sets the contents to a string" do
      expect(tag.content).to eq("Hello World")
    end

    it "sets the hash of options to the attributes" do
      expect(tag.attributes).to eq({ id: "my_id" })
    end
  end

  describe "creating a tag 'for' an object" do
    let(:model_name){ double(singular: "resource_class")}
    let(:resource_class){ double(model_name: model_name) }
    let(:resource){ double(class: resource_class, to_key: ['5'])}

    before do
      tag.build for: resource
    end

    it "sets the id to the type and id" do
      expect(tag.id).to eq("resource_class_5")
    end

    it "adds a class name" do
      expect(tag.class_list).to include("resource_class")
    end


    describe "for an object that doesn't have a model_name" do
      let(:resource_class){ double(name: 'ResourceClass') }

      before do
        tag.build for: resource
      end

      it "sets the id to the type and id" do
        expect(tag.id).to eq("resource_class_5")
      end

      it "adds a class name" do
        expect(tag.class_list).to include("resource_class")
      end
    end

    describe "with a default_id_for_prefix" do

      let(:tag) do
        Class.new(Arbre::HTML::Tag) do
          def default_id_for_prefix
            "a_prefix"
          end
        end.new
      end

      it "sets the id to the type and id" do
        expect(tag.id).to eq("a_prefix_resource_class_5")
      end

    end
  end

  describe "creating a tag with a for attribute" do
    it "sets the `for` attribute when a string is given" do
      tag.build for: "email"
      expect(tag.attributes[:for]).to eq "email"
    end

    it "sets the `for` attribute when a symbol is given" do
      tag.build for: :email
      expect(tag.attributes[:for]).to eq :email
    end
  end

  describe "css class names" do

    it "adds a class" do
      tag.add_class "hello_world"
      expect(tag.class_names).to eq("hello_world")
    end

    it "removes classes" do
      tag.add_class "hello_world"
      expect(tag.class_names).to eq("hello_world")
      tag.remove_class "hello_world"
      expect(tag.class_names).to eq("")
    end

    it "does not add a class if it already exists" do
      tag.add_class "hello_world"
      tag.add_class "hello_world"
      expect(tag.class_names).to eq("hello_world")
    end

    it "separates classes with space" do
      tag.add_class "hello world"
      expect(tag.class_list.size).to eq(2)
    end

    it "creates a class list from a string" do
      tag = described_class.new
      tag.build(class: "first-class")
      tag.add_class "second-class"
      expect(tag.class_list.size).to eq(2)
    end

  end

end
