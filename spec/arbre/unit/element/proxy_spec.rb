# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Arbre::Element::Proxy do
  let(:element) { Arbre::HTML::Span.new }
  let(:proxy) { described_class.new(element) }

  it "delegates methods to the element" do
    element.content = "Hello"
    expect(proxy.to_s).to eq("<span>Hello</span>\n")
  end

  it "responds to methods of the element" do
    expect(proxy.respond_to?(:add_class)).to be(true)
  end

  it "does not respond to methods the element does not have" do
    expect(proxy.respond_to?(:not_an_element_method)).to be(false)
  end

  # Responding to to_ary would make Array#flatten recurse into the element
  it "does not respond to to_ary" do
    expect(proxy).not_to respond_to(:to_ary)
    expect(proxy).not_to respond_to("to_ary")
  end

  it "raises a NoMethodError for to_ary" do
    expect { proxy.to_ary }.to raise_error(NoMethodError)
  end
end
