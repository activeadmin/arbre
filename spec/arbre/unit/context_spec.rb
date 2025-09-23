# frozen_string_literal: true
require 'spec_helper'

describe Arbre::Context do

  let(:context) do
    described_class.new do
      h1 "札幌市北区" # Add some HTML to the context
    end
  end

  it "does not increment the indent_level" do
    expect(context.indent_level).to eq(-1)
  end

  it "returns a bytesize" do
    expect(context.bytesize).to eq(25)
  end

  it "returns a length" do
    expect(context.length).to eq(25)
  end

  it "delegates missing methods to the html string" do
    expect(context).to respond_to(:index)
    expect(context.index('<')).to eq(0)
  end

  it "uses a cached version of the HTML for method delegation" do
    expect(context).to receive(:to_s).once.and_return("<h1>札幌市北区</h1>")
    expect(context.index('<')).to eq(0)
    expect(context.index('<')).to eq(0)
  end

  context "when an error is raised in a nested block" do
    let(:context) do
      described_class.new do
        ul do
          li do
            'item one'
          end
          li do
            raise 'error talking to the db'
          end
        end
      rescue StandardError
        para 'Uh oh! DB call failed'
      end
    end

    it "properly resets the element buffer" do
      expect(context.current_arbre_element).to be_a(described_class)
    end
  end
end
