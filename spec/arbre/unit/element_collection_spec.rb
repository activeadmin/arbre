# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Arbre::ElementCollection do
  let(:first) { Arbre::HTML::Span.new }
  let(:second) { Arbre::HTML::Span.new }
  let(:collection) { described_class.new([first, second]) }

  it "returns a collection when subtracting" do
    result = collection - [first]
    expect(result).to be_an_instance_of(described_class)
    expect(result).to eq([second])
  end

  it "returns a collection when intersecting" do
    result = collection & [second]
    expect(result).to be_an_instance_of(described_class)
    expect(result).to eq([second])
  end

  it "renders the elements as an html safe string" do
    first.content = "<one>"
    html = collection.to_s
    expect(html).to eq("<span>&lt;one&gt;</span>\n<span></span>\n")
    expect(html).to be_html_safe
  end
end
