# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Arbre::HTML::Document do
  let(:document){ described_class.new }

  describe "#document" do
    it "returns itself" do
      expect(document.document).to be(document)
    end
  end

  describe "#to_s" do
    subject { document.to_s }

    before do
      document.build
    end

    it { is_expected.to eq "<!DOCTYPE html><html></html>\n" }
  end
end
