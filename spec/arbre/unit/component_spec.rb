# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Arbre::Component do
  let(:assigns) { {} }
  let(:helpers) { nil }
  let(:component_class) do
    Class.new(described_class) do
      def build
        h2 "Hello World"
      end
    end
  end
  let(:component) { component_class.new }

  it "is a subclass of an html div" do
    expect(described_class.ancestors).to include(Arbre::HTML::Div)
  end

  it "renders to a div, even as a subclass" do
    expect(component.tag_name).to eq('div')
  end

  it "does not have a class list" do
    expect(component.class_list.to_s).to eq("")
    expect(component.class_list.empty?).to be(true)
  end

  describe "a builder method" do
    # builder_method defines the method on Arbre::Element::BuilderMethods,
    # which every element includes, so remove it again after each example.
    before do
      stub_const("MockComponent", component_class)
      MockComponent.builder_method :mock_component
    end

    after do
      if Arbre::Element::BuilderMethods.method_defined?(:mock_component)
        Arbre::Element::BuilderMethods.remove_method(:mock_component)
      end
    end

    it "renders the object using the builder method name" do
      expect(arbre {
        mock_component
      }.to_s).to eq <<~HTML
        <div>
          <h2>Hello World</h2>
        </div>
        HTML
    end
  end
end
