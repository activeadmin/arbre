# coding: utf-8
require 'spec_helper'

describe Arbre::Context do

  let(:context) do
    Arbre::Context.new do
      h1 "札幌市北区" # Add some HTML to the context
    end
  end

  it "should not increment the indent_level" do
    expect(context.indent_level).to eq(-1)
  end

  it "should return a bytesize" do
    expect(context.bytesize).to eq(25)
  end

  it "should return a length" do
    expect(context.length).to eq(25)
  end

  it "should delegate missing methods to the html string" do
    expect(context).to respond_to(:index)
    expect(context.index('<')).to eq(0)
  end

  it "should use a cached version of the HTML for method delegation" do
    expect(context).to receive(:to_s).once.and_return("<h1>札幌市北区</h1>")
    expect(context.index('<')).to eq(0)
    expect(context.index('<')).to eq(0)
  end

end
