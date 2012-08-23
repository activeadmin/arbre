require 'spec_helper'

describe Arbre::Element do

  let(:element){ Arbre::Element.new }

  context "when initialized" do

    it "should have no children" do
      element.children.should be_empty
    end

    it "should have no parent" do
      element.parent.should be_nil
    end

    it "should respond to the HTML builder methods" do
      element.should respond_to(:span)
    end

    it "should have a set of local assigns" do
      context = Arbre::Context.new :hello => "World"
      element = Arbre::Element.new(context)
      element.assigns[:hello].should == "World"
    end

    it "should have an empty hash with no local assigns" do
      element.assigns.should == {}
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
      element.helper_method.should == "helper method"
    end

    it "should raise a NoMethodError if not found" do
      lambda {
        element.a_method_that_doesnt_exist
      }.should raise_error(NoMethodError)
    end

  end

  describe "passing in assigns" do
    let(:post){ stub }
    let(:assigns){ {:post => post} }

    it "should be accessible via a method call" do
      element = Arbre::Element.new(Arbre::Context.new(assigns))
      element.post.should == post
    end

  end

  describe "adding a child" do

    let(:child){ Arbre::Element.new }

    before do
      element.add_child child
    end

    it "should add the child to the parent" do
      element.children.first.should == child
    end

    it "should set the parent of the child" do
      child.parent.should == element
    end

    context "when the child is nil" do

      let(:child){ nil }

      it "should not add the child" do
        element.children.should be_empty
      end

    end

    context "when the child is a string" do

      let(:child){ "Hello World" }

      it "should add as a TextNode" do
        element.children.first.should be_instance_of(Arbre::HTML::TextNode)
        element.children.first.to_s.should == "Hello World"
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
        element.children.size.should == 1
      end

      it "should add the string as a child" do
        element.children.first.to_s.should == "Goodbye"
      end

      it "should html escape the string" do
        string = "Goodbye <br />"
        element.content = string
        element.content.to_s.should == "Goodbye &lt;br /&gt;"
      end
    end

    context "when an element" do
      let(:content_element){ Arbre::Element.new }

      before do
        element.content = content_element
      end

      it "should set the content tag" do
        element.children.first.should == content_element
      end

      it "should set the tags parent" do
        content_element.parent.should == element
      end
    end

    context "when an array of tags" do
      let(:first){ Arbre::Element.new }
      let(:second){ Arbre::Element.new }

      before do
        element.content = [first, second]
      end

      it "should set the content tag" do
        element.children.first.should == first
      end

      it "should set the tags parent" do
        element.children.first.parent.should == element
      end
    end

  end

  describe "rendering to html" do

    before  { @separator = $, }
    after   { $, = @separator }
    let(:collection){ element + "hello world" }

    it "should render the children collection" do
      element.children.should_receive(:to_s).and_return("content")
      element.to_s.should == "content"
    end

    it "should render collection when is set the default separator" do
      $, = "_"
      collection.to_s.should == "hello world"
    end

    it "should render collection when is not set the default separator" do
      collection.to_s.should == "hello world"
    end

  end

  describe "adding elements together" do

    context "when both elements are tags" do
      let(:first){ Arbre::Element.new }
      let(:second){ Arbre::Element.new }
      let(:collection){ first + second }

      it "should return an instance of Collection" do
        collection.should be_an_instance_of(Arbre::ElementCollection)
      end

      it "should return the elements in the collection" do
        collection.size.should == 2
        collection.first.should == first
        collection[1].should == second
      end
    end

    context "when the left is a collection and the right is a tag" do
      let(:first){ Arbre::Element.new }
      let(:second){ Arbre::Element.new }
      let(:third){ Arbre::Element.new }
      let(:collection){ Arbre::ElementCollection.new([first, second]) + third}

      it "should return an instance of Collection" do
        collection.should be_an_instance_of(Arbre::ElementCollection)
      end

      it "should return the elements in the collection flattened" do
        collection.size.should == 3
        collection[0].should == first
        collection[1].should == second
        collection[2].should == third
      end
    end

    context "when the right is a collection and the left is a tag" do
      let(:first){ Arbre::Element.new }
      let(:second){ Arbre::Element.new }
      let(:third){ Arbre::Element.new }
      let(:collection){ first + Arbre::ElementCollection.new([second,third]) }

      it "should return an instance of Collection" do
        collection.should be_an_instance_of(Arbre::ElementCollection)
      end

      it "should return the elements in the collection flattened" do
        collection.size.should == 3
        collection[0].should == first
        collection[1].should == second
        collection[2].should == third
      end
    end

    context "when the left is a tag and the right is a string" do
      let(:element){ Arbre::Element.new }
      let(:collection){ element + "Hello World"}

      it "should return an instance of Collection" do
        collection.should be_an_instance_of(Arbre::ElementCollection)
      end

      it "should return the elements in the collection" do
        collection.size.should == 2
        collection[0].should == element
        collection[1].should be_an_instance_of(Arbre::HTML::TextNode)
      end
    end

    context "when the left is a string and the right is a tag" do
      let(:collection){ "hello World" + Arbre::Element.new}

      it "should return a string" do
        collection.strip.chomp.should == "hello World"
      end
    end
  end

end
