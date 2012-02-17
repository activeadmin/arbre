# coding: utf-8
require 'spec_helper'

describe Arbre::Context do

  let(:context) do
    Arbre::Context.new do
      h1 "札幌市北区" # Add some HTML to the context
    end
  end

  it "should not increment the indent_level" do
    context.indent_level.should == -1
  end

  it "should return a bytesize" do
    context.bytesize.should == 25
  end

  it "should return a length" do
    context.length.should == 25
  end

  it "should delegate missing methods to the html string" do
    context.should respond_to(:index)
    context.index('<').should == 0
  end

  it "should use a cached version of the HTML for method delegation" do
    context.should_receive(:to_s).once.and_return("<h1>札幌市北区</h1>")
    context.index('<').should == 0
    context.index('<').should == 0
  end

end
