require 'rails/rails_spec_helper'

describe "Building links" do

  let(:assigns){ {} }
  let(:helpers){ mock_action_view }
  let(:html) { link.to_s }

  describe "with a block" do

    let(:link) do
      arbre do
        link_to('/link_path') { i("Link text", class: 'link-class') }
      end
    end

    it "should build a link" do
      expect(html).to eq <<~HTML
        <a href="/link_path">
          <i class="link-class">Link text</i>
        </a>
      HTML
    end

  end

  describe "without a block" do

    let(:link) do
      arbre do
        link_to('Link text', '/link_path')
      end
    end

    it "should build a link" do
      expect(html).to eq <<~HTML
        <a href="/link_path">Link text</a>
      HTML
    end

  end
end
