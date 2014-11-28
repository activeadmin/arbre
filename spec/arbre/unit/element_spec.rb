require 'spec_helper'

describe Arbre::Element do

  let(:element){ Arbre::Element.new }

  context "when initialized" do

    it "should have no children" do
      expect(element.children).to be_empty
    end

    it "should have no parent" do
      expect(element.parent).to be_nil
    end

    it "should respond to the HTML builder methods" do
      expect(element).to respond_to(:span)
    end

    it "should have a set of local assigns" do
      context = Arbre::Context.new hello: "World"
      element = Arbre::Element.new(context)
      expect(element.assigns[:hello]).to eq("World")
    end

    it "should have an empty hash with no local assigns" do
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

    let(:element){ Arbre::Element.new(Arbre::Context.new(nil, helper.new)) }

    it "should call methods on the helper object and return TextNode objects" do
      expect(element.helper_method).to eq("helper method")
    end

    it "should raise a NoMethodError if not found" do
      expect {
        element.a_method_that_doesnt_exist
      }.to raise_error(NoMethodError)
    end

  end

  describe "passing in assigns" do
    let(:post){ double }
    let(:assigns){ {post: post} }

    it "should be accessible via a method call" do
      element = Arbre::Element.new(Arbre::Context.new(assigns))
      expect(element.post).to eq(post)
    end

  end

  it "to_a.flatten should not infinitely recurse" do
    Timeout.timeout(1) do
      element.to_a.flatten
    end
  end

  describe "adding a child" do

    let(:child){ Arbre::Element.new }

    before do
      element.add_child child
    end

    it "should add the child to the parent" do
      expect(element.children.first).to eq(child)
    end

    it "should set the parent of the child" do
      expect(child.parent).to eq(element)
    end

    context "when the child is nil" do

      let(:child){ nil }

      it "should not add the child" do
        expect(element.children).to be_empty
      end

    end

    context "when the child is a string" do

      let(:child){ "Hello World" }

      it "should add as a TextNode" do
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

      it "should clear the existing children" do
        expect(element.children.size).to eq(1)
      end

      it "should add the string as a child" do
        expect(element.children.first.to_s).to eq("Goodbye")
      end

      it "should html escape the string" do
        string = "Goodbye <br />"
        element.content = string
        expect(element.content.to_s).to eq("Goodbye &lt;br /&gt;")
      end
    end

    context "when an element" do
      let(:content_element){ Arbre::Element.new }

      before do
        element.content = content_element
      end

      it "should set the content tag" do
        expect(element.children.first).to eq(content_element)
      end

      it "should set the tags parent" do
        expect(content_element.parent).to eq(element)
      end
    end

    context "when an array of tags" do
      let(:first){ Arbre::Element.new }
      let(:second){ Arbre::Element.new }

      before do
        element.content = [first, second]
      end

      it "should set the content tag" do
        expect(element.children.first).to eq(first)
      end

      it "should set the tags parent" do
        expect(element.children.first.parent).to eq(element)
      end
    end

  end

  describe "rendering to html" do

    before  { @separator = $, }
    after   { $, = @separator }
    let(:collection){ element + "hello world" }

    it "should render the children collection" do
      expect(element.children).to receive(:to_s).and_return("content")
      expect(element.to_s).to eq("content")
    end

    it "should render collection when is set the default separator" do
      $, = "_"
      expect(collection.to_s).to eq("hello world")
    end

    it "should render collection when is not set the default separator" do
      expect(collection.to_s).to eq("hello world")
    end

  end

  describe "adding elements together" do

    context "when both elements are tags" do
      let(:first){ Arbre::Element.new }
      let(:second){ Arbre::Element.new }
      let(:collection){ first + second }

      it "should return an instance of Collection" do
        expect(collection).to be_an_instance_of(Arbre::ElementCollection)
      end

      it "should return the elements in the collection" do
        expect(collection.size).to eq(2)
        expect(collection.first).to eq(first)
        expect(collection[1]).to eq(second)
      end
    end

    context "when the left is a collection and the right is a tag" do
      let(:first){ Arbre::Element.new }
      let(:second){ Arbre::Element.new }
      let(:third){ Arbre::Element.new }
      let(:collection){ Arbre::ElementCollection.new([first, second]) + third}

      it "should return an instance of Collection" do
        expect(collection).to be_an_instance_of(Arbre::ElementCollection)
      end

      it "should return the elements in the collection flattened" do
        expect(collection.size).to eq(3)
        expect(collection[0]).to eq(first)
        expect(collection[1]).to eq(second)
        expect(collection[2]).to eq(third)
      end
    end

    context "when the right is a collection and the left is a tag" do
      let(:first){ Arbre::Element.new }
      let(:second){ Arbre::Element.new }
      let(:third){ Arbre::Element.new }
      let(:collection){ first + Arbre::ElementCollection.new([second,third]) }

      it "should return an instance of Collection" do
        expect(collection).to be_an_instance_of(Arbre::ElementCollection)
      end

      it "should return the elements in the collection flattened" do
        expect(collection.size).to eq(3)
        expect(collection[0]).to eq(first)
        expect(collection[1]).to eq(second)
        expect(collection[2]).to eq(third)
      end
    end

    context "when the left is a tag and the right is a string" do
      let(:element){ Arbre::Element.new }
      let(:collection){ element + "Hello World"}

      it "should return an instance of Collection" do
        expect(collection).to be_an_instance_of(Arbre::ElementCollection)
      end

      it "should return the elements in the collection" do
        expect(collection.size).to eq(2)
        expect(collection[0]).to eq(element)
        expect(collection[1]).to be_an_instance_of(Arbre::HTML::TextNode)
      end
    end

    context "when the left is a string and the right is a tag" do
      let(:collection){ "hello World" + Arbre::Element.new}

      it "should return a string" do
        expect(collection.strip.chomp).to eq("hello World")
      end
    end
  end

end
