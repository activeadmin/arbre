# frozen_string_literal: true
require 'spec_helper'

module RenderingSpec
  class NilToS < Arbre::Component
    def to_s = nil
  end

  class IntegerToS < Arbre::Component
    def to_s = 42
  end

  class WrappingToS < Arbre::Component
    def to_s = "<!-- a -->".html_safe + super
  end

  class FormLike < Arbre::Component
    def opening_tag = '<form class="f">'
    def closing_tag = "</form>"
  end

  class CustomIndent < Arbre::Component
    def indent(open_tag, child_content, close_tag) = "[#{open_tag}|#{child_content}|#{close_tag}]"
  end

  class CustomContent < Arbre::Component
    def content = "custom".html_safe
  end

  class NeverText < Arbre::Component
    def child_is_text? = false
  end

  class FixedLevel < Arbre::Component
    def indent_level = 3
  end

  class VoidWithOpeningTag < Arbre::HTML::Tag
    def tag_name = "br"
    def opening_tag = '<br data-x="1">'
  end

  class RemovesItself < Arbre::HTML::Span
    def tag_name = "span"
    def to_s = super.tap { parent&.remove_child(self) }
  end

  class RawText < Arbre::HTML::TextNode
    def to_s = "<raw>"
  end

  class AddsSibling < Arbre::HTML::Span
    def tag_name = "span"

    def to_s
      parent << Arbre::HTML::TextNode.from_string("added") unless @added
      @added = true
      super
    end
  end
end

describe Arbre::Element::Rendering do
  def render(&block)
    Arbre::Context.new(&block).to_s
  end

  it "renders stock tags without calling Tag#indent" do
    expect_any_instance_of(Arbre::HTML::Tag).not_to receive(:indent) # rubocop:disable RSpec/AnyInstance
    expect(render { div { span "a" } }).to eq("<div>\n  <span>a</span>\n</div>\n")
  end

  it "skips a child whose to_s returns nil and appends an Integer as digits" do
    html = render do
      div do
        insert_tag RenderingSpec::NilToS
        insert_tag RenderingSpec::IntegerToS
        span "after"
      end
    end

    expect(html).to eq("<div>\n42  <span>after</span>\n</div>\n")
  end

  it "renders a to_s override that calls super" do
    html = render { div { insert_tag(RenderingSpec::WrappingToS) { span "w" } } }

    expect(html).to eq("<div>\n<!-- a -->  <div>\n    <span>w</span>\n  </div>\n</div>\n")
  end

  it "renders a to_s defined on a single element" do
    html = render do
      div do
        first = span "a"
        def first.to_s = "<x/>"
        span "b"
      end
    end

    expect(html).to eq("<div>\n<x/>  <span>b</span>\n</div>\n")
  end

  it "renders a to_s from a module the element is extended with" do
    wrapper = Module.new { def to_s = "[#{super.chomp}]" }

    expect(render { div { span("a").extend(wrapper) } }).to eq("<div>\n[  <span>a</span>]</div>\n")
  end

  it "renders a to_s prepended after the class was rendered" do
    klass = Class.new(Arbre::HTML::Span) { def tag_name = "span" }
    context = Arbre::Context.new { div { insert_tag klass, "x" } }
    expect(context.to_s).to include("<span>x</span>")

    klass.prepend(Module.new { def to_s = "<late/>" })

    expect(Arbre::Context.new { div { insert_tag klass, "x" } }.to_s).to eq("<div>\n<late/></div>\n")
  end

  it "lays the parent out again when a child adds a sibling while rendering" do
    html = render { div { insert_tag RenderingSpec::AddsSibling, "m" } }

    expect(html).to eq("<div>\n  <span>m</span>\nadded</div>\n")
  end

  it "flattens nested attribute hashes and drops nil values" do
    html = render { div data: { a: 1, b: { c: "<d>" } }, "aria-label": nil, class: "x" }

    expect(html).to eq(%(<div data-a="1" data-b-c="&lt;d&gt;" class="x"></div>\n))
  end

  it "keeps the last value when a flattened attribute name repeats" do
    expect(render { div "data-a": 1, data: { a: 2 } }).to eq(%(<div data-a="2"></div>\n))
  end

  it "drops the text of a self-closing tag" do
    expect(render { input "dropped", name: "q"; br }).to eq(%(<input name="q"/>\n<br/>\n))
  end

  it "indents a nested context at its parent's level" do
    html = render do
      div do
        span "a"
        current_arbre_element.add_child(Arbre::Context.new { span "inner"; div { para "p" } })
      end
    end

    expect(html).to eq("<div>\n  <span>a</span>\n  <span>inner</span>\n  <div>\n    <p>p</p>\n  </div>\n</div>\n")
  end

  it "indents a subtree rendered on its own by its depth in the tree" do
    item = nil
    render { div { ul { item = li { a "x" } } } }

    expect(item.to_s).to eq("    <li>\n      <a>x</a>\n    </li>\n")
  end

  it "returns a US-ASCII string like Array#join for an empty context" do
    expect(render {}.encoding).to eq(Encoding::US_ASCII)
  end

  it "does not build a context for a text node made from a string" do
    expect(Arbre::Context).not_to receive(:new)

    expect(Arbre::HTML::TextNode.from_string("<t>").to_s).to eq("&lt;t&gt;")
  end

  describe "overridden rendering hooks" do
    it "uses opening_tag and closing_tag overrides" do
      html = render { div { insert_tag(RenderingSpec::FormLike) { span "a" }; insert_tag RenderingSpec::FormLike, "t" } }

      expect(html).to eq(%(<div>\n  <form class="f">\n    <span>a</span>\n  </form>\n  <form class="f">t</form>\n</div>\n))
    end

    it "uses an indent override" do
      html = render { div { insert_tag(RenderingSpec::CustomIndent) { span "x" } } }

      expect(html).to eq("<div>\n[<div>|    <span>x</span>\n|</div>]</div>\n")
    end

    it "uses a content override" do
      html = render { div { insert_tag(RenderingSpec::CustomContent) { span "ignored" } } }

      expect(html).to eq("<div>\n  <div>\ncustom  </div>\n</div>\n")
    end

    it "uses a child_is_text? override" do
      expect(render { div { insert_tag RenderingSpec::NeverText, "text" } }).to eq("<div>\n  <div>\ntext  </div>\n</div>\n")
    end

    it "uses an indent_level override for the element and its children" do
      html = render { div { insert_tag(RenderingSpec::FixedLevel) { span "x" } } }

      expect(html).to eq("<div>\n      <div>\n        <span>x</span>\n      </div>\n</div>\n")
    end

    it "closes a self-closing tag that has an opening_tag override" do
      html = render { div { insert_tag RenderingSpec::VoidWithOpeningTag; insert_tag RenderingSpec::VoidWithOpeningTag, "t" } }

      expect(html).to eq(%(<div>\n  <br data-x="1"/>\n  <br data-x="1"/>\n</div>\n))
    end

    it "uses a to_s override on a text node" do
      expect(render { div { current_arbre_element.add_child RenderingSpec::RawText.from_string("x") } }).to eq("<div><raw></div>\n")
    end

    it "renders a nested document with its doctype" do
      html = render { div { insert_tag Arbre::HTML::Document } }

      expect(html).to start_with("<div>\n<!DOCTYPE html>  <html>\n    <head>\n")
    end

    it "renders through the fast path again after an override is removed" do
      klass = Class.new(Arbre::HTML::Span) do
        def tag_name = "span"
        def to_s = "<custom/>"
      end
      expect(Arbre::Context.new { insert_tag klass, "x" }.to_s).to eq("<custom/>")

      klass.send(:remove_method, :to_s)

      expect(Arbre::Context.new { insert_tag klass, "x" }.to_s).to eq("<span>x</span>\n")
    end

    it "uses a to_s override on an extended children collection" do
      parent = Arbre::HTML::Div.new
      parent.build
      parent.children.extend(Module.new { def to_s = "stub" })

      expect(parent.to_s).to eq("<div>stub</div>\n")
    end
  end

  it "lays the parent out again when a child removes itself while rendering" do
    html = render { div { insert_tag RenderingSpec::RemovesItself, "r" }; img { insert_tag RenderingSpec::RemovesItself, "r" } }

    expect(html).to eq("<div>  <span>r</span>\n</div>\n<img/>\n")
  end

  describe Arbre::HTML::TextNode do
    let(:node) { described_class.from_string("x") }

    it "builds its context on first use" do
      expect(node.arbre_context).to be_a(Arbre::Context)
      expect(node.arbre_context).to equal(node.arbre_context)
    end

    it "has no children" do
      expect(node.children?).to be(false)
      expect(node.remove_child(Arbre::HTML::Div.new)).to be_nil
      expect { node.content = "y" }.to raise_error("TextNodes do not have children")
    end
  end

  describe "building" do
    let(:component) do
      Class.new(Arbre::Component) do
        def insert_tag(klass, *args, &block)
          super.tap { |tag| tag.add_class("child") }
        end
      end
    end

    it "calls an insert_tag override on the receiver" do
      parent = component
      html = render { insert_tag(parent) { |c| c.span "a" } }

      expect(html).to eq(%(<div>\n  <span class="child">a</span>\n</div>\n))
    end

    it "calls an insert_tag override defined after the class was used" do
      parent = Class.new(Arbre::Component)
      render { insert_tag(parent) { |c| c.span "a" } }
      parent.class_eval { def insert_tag(*) = super.tap { |tag| tag.set_attribute(:title, "late") } }

      expect(render { insert_tag(parent) { |c| c.span "a" } }).to include(%(<span title="late">a</span>))
    end

    it "calls extract_arguments and set_for_attribute overrides" do
      klass = Class.new(Arbre::HTML::Span) do
        def tag_name = "span"
        def extract_arguments(args) = super.merge(class: "default")

        def set_for_attribute(record)
          set_attribute(:"data-for", record.inspect)
          super
        end
      end

      html = render { insert_tag klass, "x" }

      expect(html).to eq(%(<span data-for="nil" class="default">x</span>\n))
    end
  end
end
