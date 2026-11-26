# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Arbre::HTML::TextNode do
  let(:text_node){ described_class.new }

  describe '#class_list' do
    subject { text_node.class_list }

    it { is_expected.to be_empty }
  end

  describe '#tag_name' do
    subject { text_node.tag_name }

    it { is_expected.to be_nil }
  end

  describe '#add_child' do
    it 'raises an error' do
      expect { text_node.add_child('child') }.to raise_error(RuntimeError, 'TextNodes do not have children')
    end
  end

  describe '#to_s' do
    it 'renders the content' do
      text_node.build('Test')
      expect(text_node.to_s).to eq 'Test'
    end

    it 'escapes html' do
      text_node.build('<br>')
      expect(text_node.to_s).to eq '&lt;br&gt;'
    end

    it 'does not escape html safe content' do
      text_node.build('<br>'.html_safe)
      expect(text_node.to_s).to eq '<br>'
    end
  end
end
