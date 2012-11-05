require 'spec_helper'

describe Arbre::HTML::Tag, "Attributes" do

  let(:tag){ Arbre::HTML::Tag.new }

  describe "attributes" do

    before { tag.build :id => "my_id" }

    it "should have an attributes hash" do
      tag.attributes.should == {:id => "my_id"}
    end

    it "should render the attributes to html" do
      tag.to_s.should == <<-HTML
<tag id="my_id"></tag>
HTML
    end

    it "should get an attribute value" do
      tag.attr(:id).should == "my_id"
    end

    describe "#has_attribute?" do
      context "when the attribute exists" do
        it "should return true" do
          tag.has_attribute?(:id).should == true
        end
      end

      context "when the attribute does not exist" do
        it "should return false" do
          tag.has_attribute?(:class).should == false
        end
      end
    end

    it "should remove an attribute" do
      tag.attributes.should == {:id => "my_id"}
      tag.remove_attribute(:id).should == "my_id"
      tag.attributes.should == {}
    end
  end

  describe "rendering attributes" do
    it "should html safe the attribute values" do
      tag.set_attribute(:class, "\">bad things!")
      tag.to_s.should == <<-HTML
<tag class="&quot;&gt;bad things!"></tag>
HTML
    end
    it "should should escape the attribute names" do
      tag.set_attribute(">bad", "things")
      tag.to_s.should == <<-HTML
<tag &gt;bad="things"></tag>
HTML
    end
  end

  describe "#data=" do
    it "should assign data attributes" do
      tag.data = {:whatever => true}
      tag.to_s.should == <<-HTML
<tag data-whatever="true"></tag>
HTML
    end
  end

  describe "#data[]=" do
    it "should assign an html5 data attribute when none already assigned" do
      tag.data[:whatever] = false
      tag.data.should eq(:whatever => false)
      HTML
    end

    it "should assign an html5 data attribute" do
      tag.data = {:riot => true}
      tag.data[:whatever] = false
      tag.data.should eq(:riot => true, :whatever => false)
      tag.to_s.should == <<-HTML
<tag data-riot="true" data-whatever="false"></tag>
      HTML
    end
  end

  describe "#data" do
    it "should return an empty hash when none assigned" do
      tag.data.should == {}
    end

    it "should return an html5 data attribute hash" do
      tag.attributes["data-whatever"] = true
      tag.data.should eq(:whatever => true)
      tag.to_s.should == <<-HTML
<tag data-whatever="true"></tag>
HTML
    end
  end
end
