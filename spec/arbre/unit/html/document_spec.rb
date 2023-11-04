# frozen_string_literal: true
require 'spec_helper'

describe Arbre::HTML::Document do
  let(:document){ described_class.new }

  describe "#to_s" do
    subject { document.to_s }

    before do
      document.build
    end

    it { is_expected.to eq "<!DOCTYPE html><html></html>\n" }
  end
end
