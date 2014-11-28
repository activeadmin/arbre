require 'spec_helper'

describe Arbre::Element, "Finder Methods" do
  let(:assigns){ {} }
  let(:helpers){ {} }

  describe "finding elements by tag name" do

    it "should return 0 when no elements exist" do
      expect(arbre {
        div
      }.get_elements_by_tag_name("li").size).to eq(0)
    end

    it "should return a child element" do
      html = arbre do
        ul
        li
        ul
      end
      elements = html.get_elements_by_tag_name("li")
      expect(elements.size).to eq(1)
      expect(elements[0]).to be_instance_of(Arbre::HTML::Li)
    end

    it "should return multple child elements" do
      html = arbre do
        ul
        li
        ul
        li
      end
      elements = html.get_elements_by_tag_name("li")
      expect(elements.size).to eq(2)
      expect(elements[0]).to be_instance_of(Arbre::HTML::Li)
      expect(elements[1]).to be_instance_of(Arbre::HTML::Li)
    end

    it "should return children's child elements" do
      html = arbre do
        ul
        li do
          li
        end
      end
      elements = html.get_elements_by_tag_name("li")
      expect(elements.size).to eq(2)
      expect(elements[0]).to be_instance_of(Arbre::HTML::Li)
      expect(elements[1]).to be_instance_of(Arbre::HTML::Li)
      expect(elements[1].parent).to eq(elements[0])
    end
  end

  #TODO: describe "finding an element by id"

  describe "finding an element by a class name" do

    it "should return 0 when no elements exist" do
      expect(arbre {
        div
      }.get_elements_by_class_name("my_class").size).to eq(0)
    end

    it "should allow text nodes on tree" do
      expect(arbre {
        text_node "text"
      }.get_elements_by_class_name("my_class").size).to eq(0)
    end

    it "should return a child element" do
      html = arbre do
        div class: "some_class"
        div class: "my_class"
      end
      elements = html.get_elements_by_class_name("my_class")
      expect(elements.size).to eq(1)
      expect(elements[0]).to be_instance_of(Arbre::HTML::Div)
    end

    it "should return multple child elements" do
      html = arbre do
        div class: "some_class"
        div class: "my_class"
        div class: "my_class"
      end
      elements = html.get_elements_by_class_name("my_class")
      expect(elements.size).to eq(2)
      expect(elements[0]).to be_instance_of(Arbre::HTML::Div)
      expect(elements[1]).to be_instance_of(Arbre::HTML::Div)
    end

    it "should return elements that match one of several classes" do
      html = arbre do
        div class: "some_class this_class"
        div class: "some_class"
        div class: "other_class"

      end
      elements = html.get_elements_by_class_name("this_class")
      expect(elements.size).to eq(1)
      expect(elements[0]).to be_instance_of(Arbre::HTML::Div)
    end

    it "should return a grandchild element" do
      html = arbre do
        div class: "some_class" do
          div class: "my_class"
        end
      end
      elements = html.get_elements_by_class_name("my_class")
      expect(elements.size).to eq(1)
      expect(elements[0]).to be_instance_of(Arbre::HTML::Div)
    end

  end
end
