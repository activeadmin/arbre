# frozen_string_literal: true
require 'spec_helper'

describe Arbre::HTML::TextNode do
  let(:text_node){ described_class.new }

  describe '#class_list' do
    subject { text_node.class_list }

    it { is_expected.to be_empty }
  end

  describe '#tag_name' do
    subject { text_node.tag_name }

    it { is_expected.to be_nil }
  end

  describe '#to_s' do
    subject { text_node.build('Test').to_s }

    it { is_expected.to eq 'Test' }
  end
end
