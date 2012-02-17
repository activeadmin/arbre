require 'spec_helper'

# A mock subclass to play with
class MockComponent < Arbre::Component; end

describe Arbre::Component do

  let(:component_class){ MockComponent }
  let(:component){ component_class.new }

  it "should be a subclass of an html div" do
    Arbre::Component.ancestors.should include(Arbre::HTML::Div)
  end

  it "should render to a div, even as a subclass" do
    component.tag_name.should == 'div'
  end

  it "should add a class by default" do
    component.class_list.should include("mock_component")
  end

end
