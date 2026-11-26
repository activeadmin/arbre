# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Arbre::Element do

  let(:element){ described_class.new }

  context "when initialized" do

    it "has no children" do
      expect(element.children).to be_empty
    end

    it "has no parent" do
      expect(element.parent).to be_nil
    end

    it "responds to the HTML builder methods" do
      expect(element).to respond_to(:span)
    end

    it "has a set of local assigns" do
      context = Arbre::Context.new hello: "World"
      element = described_class.new(context)
      expect(element.assigns[:hello]).to eq("World")
    end

    it "has an empty hash with no local assigns" do
      expect(element.assigns).to eq({})
    end

  end

  describe "passing in a helper object" do

    let(:helper) do
      Class.new do
        def helper_method
          "helper method"
        end
      end
    end

    let(:element){ described_class.new(Arbre::Context.new(nil, helper.new)) }

    it "calls methods on the helper object and return TextNode objects" do
      expect(element.helper_method).to eq("helper method")
    end

    it "raises a NoMethodError if not found" do
      expect {
        element.a_method_that_doesnt_exist
      }.to raise_error(NoMethodError)
    end

  end

  describe "passing in assigns" do
    let(:post)   { double       }
    let(:assigns){ {post: post} }

    it "is accessible via a method call" do
      element = described_class.new(Arbre::Context.new(assigns))
      expect(element.post).to eq(post)
    end

  end

  it "to_a.flatten should not infinitely recurse" do
    expect {
      Timeout.timeout(1) do
        element.to_a.flatten
      end
    }.not_to raise_error
  end

  describe "adding a child" do

    let(:child){ described_class.new }

    before do
      element.add_child child
    end

    it "adds the child to the parent" do
      expect(element.children.first).to eq(child)
    end

    it "sets the parent of the child" do
      expect(child.parent).to eq(element)
    end

    context "when the child is nil" do

      let(:child){ nil }

      it "does not add the child" do
        expect(element.children).to be_empty
      end

    end

    context "when the child is a string" do

      let(:child){ "Hello World" }

      it "adds as a TextNode" do
        expect(element.children.first).to be_instance_of(Arbre::HTML::TextNode)
        expect(element.children.first.to_s).to eq("Hello World")
      end

    end
  end

  describe "setting the content" do

    context "when a string" do

      before do
        element.add_child "Hello World"
        element.content = "Goodbye"
      end

      it "clears the existing children" do
        expect(element.children.size).to eq(1)
      end

      it "adds the string as a child" do
        expect(element.children.first.to_s).to eq("Goodbye")
      end

      it "htmls escape the string" do
        string = "Goodbye <br />"
        element.content = string
        expect(element.content.to_s).to eq("Goodbye &lt;br /&gt;")
      end
    end

    context "when an element" do
      let(:content_element){ described_class.new }

      before do
        element.content = content_element
      end

      it "sets the content tag" do
        expect(element.children.first).to eq(content_element)
      end

      it "sets the tags parent" do
        expect(content_element.parent).to eq(element)
      end
    end

    context "when an array of tags" do
      let(:first){ described_class.new }
      let(:second){ described_class.new }

      before do
        element.content = [first, second]
      end

      it "sets the content tag" do
        expect(element.children.first).to eq(first)
      end

      it "sets the tags parent" do
        expect(element.children.first.parent).to eq(element)
      end
    end

  end

  describe "rendering to html" do

    around do |example|
      separator = $,
      example.run
    ensure
      without_warnings { $, = separator }
    end

    let(:collection){ element + "hello world" }

    it "renders the children collection" do
      expect(element.children).to receive(:to_s).and_return("content")
      expect(element.to_s).to eq("content")
    end

    it "renders collection when is set the default separator" do
      without_warnings { $, = "_" }

      expect(collection.to_s).to eq("hello world")
    end

    it "renders collection when is not set the default separator" do
      expect(collection.to_s).to eq("hello world")
    end

    it "uses the rendered html for #html_safe, #inspect and #to_str" do
      element.add_child "<b>"
      expect(element.html_safe).to eq("&lt;b&gt;")
      expect(element.inspect).to eq("&lt;b&gt;")
      expect(element.to_str).to eq("&lt;b&gt;")
    end

    it "yields the rendered html once from #each" do
      element.add_child "hello"
      expect { |block| element.each(&block) }.to yield_with_args("hello")
    end

    private

    # Assigning $, emits a deprecation warning
    def without_warnings
      old_verbose = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = old_verbose
    end
  end

  describe "ancestors" do
    let(:grandparent){ described_class.new }
    let(:parent){ Arbre::HTML::Div.new }

    before do
      grandparent.add_child parent
      parent.add_child element
    end

    it "is empty without a parent" do
      expect(grandparent.ancestors).to eq([])
    end

    it "lists parents from the closest to the furthest" do
      expect(element.ancestors).to eq([parent, grandparent])
    end

    it "finds the first ancestor of a type" do
      expect(element.find_first_ancestor(described_class)).to eq(parent)
      expect(element.find_first_ancestor(Arbre::HTML::Div)).to eq(parent)
    end

    it "returns nil when no ancestor is of the type" do
      expect(element.find_first_ancestor(Arbre::HTML::Span)).to be_nil
    end
  end

  describe "moving a child to a new parent" do
    let(:old_parent){ described_class.new }
    let(:new_parent){ described_class.new }

    before do
      old_parent.add_child element
      new_parent.add_child element
    end

    it "removes the child from its previous parent" do
      expect(old_parent.children).to be_empty
    end

    it "adds the child to its new parent" do
      expect(new_parent.children).to eq([element])
      expect(element.parent).to eq(new_parent)
    end
  end

  describe "removing a child" do
    let(:child){ described_class.new }

    before do
      element.add_child child
      element.remove_child child
    end

    it "removes the child" do
      expect(element.children).to be_empty
    end

    it "unsets the parent of the child" do
      expect(child.parent).to be_nil
    end
  end

  describe "adding elements together" do

    context "when both elements are tags" do
      let(:first){ described_class.new }
      let(:second){ described_class.new }
      let(:collection){ first + second }

      it "returns an instance of Collection" do
        expect(collection).to be_an_instance_of(Arbre::ElementCollection)
      end

      it "returns the elements in the collection" do
        expect(collection.size).to eq(2)
        expect(collection.first).to eq(first)
        expect(collection[1]).to eq(second)
      end
    end

    context "when the left is a collection and the right is a tag" do
      let(:first){ described_class.new }
      let(:second){ described_class.new }
      let(:third){ described_class.new }
      let(:collection){ Arbre::ElementCollection.new([first, second]) + third }

      it "returns an instance of Collection" do
        expect(collection).to be_an_instance_of(Arbre::ElementCollection)
      end

      it "returns the elements in the collection flattened" do
        expect(collection.size).to eq(3)
        expect(collection[0]).to eq(first)
        expect(collection[1]).to eq(second)
        expect(collection[2]).to eq(third)
      end
    end

    context "when the right is a collection and the left is a tag" do
      let(:first){ described_class.new }
      let(:second){ described_class.new }
      let(:third){ described_class.new }
      let(:collection){ first + Arbre::ElementCollection.new([second,third]) }

      it "returns an instance of Collection" do
        expect(collection).to be_an_instance_of(Arbre::ElementCollection)
      end

      it "returns the elements in the collection flattened" do
        expect(collection.size).to eq(3)
        expect(collection[0]).to eq(first)
        expect(collection[1]).to eq(second)
        expect(collection[2]).to eq(third)
      end
    end

    context "when the left is a tag and the right is a string" do
      let(:element){ described_class.new }
      let(:collection){ element + "Hello World"}

      it "returns an instance of Collection" do
        expect(collection).to be_an_instance_of(Arbre::ElementCollection)
      end

      it "returns the elements in the collection" do
        expect(collection.size).to eq(2)
        expect(collection[0]).to eq(element)
        expect(collection[1]).to be_an_instance_of(Arbre::HTML::TextNode)
      end
    end

    context "when the left is a string and the right is a tag" do
      let(:collection){ "hello World" + described_class.new}

      it "returns a string" do
        expect(collection.strip.chomp).to eq("hello World")
      end
    end
  end

end
