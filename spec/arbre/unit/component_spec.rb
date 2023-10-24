# frozen_string_literal: true
require 'spec_helper'

# A mock subclass to play with
class MockComponent < Arbre::Component

  builder_method :mock_component

  def build
    h2 "Hello World"
  end

end

describe Arbre::Component do
  let(:assigns) { {} }
  let(:helpers) { nil }
  let(:component_class) { MockComponent }
  let(:component) { component_class.new }

  it "should be a subclass of an html div" do
    expect(Arbre::Component.ancestors).to include(Arbre::HTML::Div)
  end

  it "should render to a div, even as a subclass" do
    expect(component.tag_name).to eq('div')
  end

  it "should not have a class list" do
    expect(component.class_list.to_s).to eq("")
    expect(component.class_list.empty?).to eq(true)
  end

  it "should render the object using the builder method name" do
    comp = expect(arbre {
      mock_component
    }.to_s).to eq <<~HTML
      <div>
        <h2>Hello World</h2>
      </div>
      HTML
  end
end
