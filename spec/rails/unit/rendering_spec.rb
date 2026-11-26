# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Arbre::Rails::Rendering do
  let(:assigns) { {} }
  let(:helpers) do
    Class.new do
      attr_reader :render_args

      def initialize(rendered)
        @rendered = rendered
      end

      def render(*args)
        @render_args = args
        @rendered
      end
    end.new(rendered)
  end

  context "when the helpers render an Arbre context" do
    let(:rendered) { Arbre::Context.new { para "From a context" } }

    it "adds the context as a child of the current element" do
      html = arbre do
        div do
          render "partial"
        end
      end

      expect(html.to_s).to eq <<~HTML
        <div>
          <p>From a context</p>
        </div>
      HTML
      expect(rendered.parent).to be_a(Arbre::HTML::Div)
    end
  end

  context "when the helpers render a string" do
    let(:rendered) { "<b>bold</b>" }

    it "adds the string as an escaped text node" do
      expect(arbre { render "partial" }.to_s).to eq("&lt;b&gt;bold&lt;/b&gt;")
    end
  end

  context "when the helpers render an html safe string" do
    let(:rendered) { "<b>bold</b>".html_safe }

    it "adds the string without escaping it" do
      expect(arbre { render "partial" }.to_s).to eq("<b>bold</b>")
    end
  end

  context "when called with arguments" do
    let(:rendered) { "" }

    it "passes the arguments to the helpers" do
      arbre { render "partial", locals: { a: 1 } }
      expect(helpers.render_args).to eq(["partial", { locals: { a: 1 } }])
    end
  end
end
