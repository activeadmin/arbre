require 'spec_helper'

describe Arbre do

  let(:helpers){ nil }
  let(:assigns){ {} }

  it "should render a single element" do
    expect(arbre {
      span "Hello World"
    }.to_s).to eq("<span>Hello World</span>\n")
  end

  it "should render a child element" do
    expect(arbre {
      span do
        span "Hello World"
      end
    }.to_s).to eq <<~HTML
      <span>
        <span>Hello World</span>
      </span>
    HTML
  end

  it "should render an unordered list" do
    expect(arbre {
      ul do
        li "First"
        li "Second"
        li "Third"
      end
    }.to_s).to eq <<~HTML
      <ul>
        <li>First</li>
        <li>Second</li>
        <li>Third</li>
      </ul>
    HTML
  end

  it "should allow local variables inside the tags" do
    expect(arbre {
      first = "First"
      second = "Second"
      ul do
        li first
        li second
      end
    }.to_s).to eq <<~HTML
      <ul>
        <li>First</li>
        <li>Second</li>
      </ul>
    HTML
  end

  it "should add children and nested" do
    expect(arbre {
      div do
        ul
        li do
          li
        end
      end
    }.to_s).to eq <<~HTML
      <div>
        <ul></ul>
        <li>
          <li></li>
        </li>
      </div>
    HTML
  end


  it "should pass the element in to the block if asked for" do
    expect(arbre {
      div do |d|
        d.ul do
          li
        end
      end
    }.to_s).to eq <<~HTML
      <div>
        <ul>
          <li></li>
        </ul>
      </div>
    HTML
  end


  it "should move content tags between parents" do
    expect(arbre {
      div do
        span(ul(li))
      end
    }.to_s).to eq <<~HTML
      <div>
        <span>
          <ul>
            <li></li>
          </ul>
        </span>
      </div>
    HTML
  end

  it "should add content to the parent if the element is passed into block" do
    expect(arbre {
      div do |d|
        d.id = "my-tag"
        ul do
          li
        end
      end
    }.to_s).to eq <<~HTML
      <div id="my-tag">
        <ul>
          <li></li>
        </ul>
      </div>
    HTML
  end

  it "should have the parent set on it" do
    list, item = nil
    arbre {
      list = ul do
        li "Hello"
        item = li "World"
      end
    }
    expect(item.parent).to eq list
  end

  it "should set a string content return value with no children" do
    expect(arbre {
      li do
        "Hello World"
      end
    }.to_s).to eq <<~HTML
      <li>Hello World</li>
    HTML
  end

  it "should turn string return values into text nodes" do
    node = nil
    arbre {
      list = li do
        "Hello World"
      end
      node = list.children.first
    }
    expect(node).to be_a Arbre::HTML::TextNode
  end

  it "should not render blank arrays" do
    expect(arbre {
      tbody do
        []
      end
    }.to_s).to eq <<~HTML
      <tbody></tbody>
    HTML
  end

  describe "self-closing nodes" do

    it "should not self-close script tags" do
      expect(arbre {
        script type: 'text/javascript'
      }.to_s).to eq("<script type=\"text/javascript\"></script>\n")
    end

    it "should self-close meta tags" do
      expect(arbre {
        meta content: "text/html; charset=utf-8"
      }.to_s).to eq("<meta content=\"text/html; charset=utf-8\"/>\n")
    end

    it "should self-close link tags" do
      expect(arbre {
        link rel: "stylesheet"
      }.to_s).to eq("<link rel=\"stylesheet\"/>\n")
    end

    Arbre::HTML::Tag::SELF_CLOSING_ELEMENTS.each do |tag|
      it "should self-close #{tag} tags" do
        expect(arbre {
          send(tag)
        }.to_s).to eq("<#{tag}/>\n")
      end
    end

  end

  describe "html safe" do

    it "should escape the contents" do
      expect(arbre {
        span("<br />")
      }.to_s).to eq <<~HTML
        <span>&lt;br /&gt;</span>
      HTML
    end

    it "should return html safe strings" do
      expect(arbre {
        span("<br />")
      }.to_s).to be_html_safe
    end

    it "should not escape html passed in" do
      expect(arbre {
        span(span("<br />"))
      }.to_s).to eq <<~HTML
        <span>
          <span>&lt;br /&gt;</span>
        </span>
      HTML
    end

    it "should escape string contents when passed in block" do
      expect(arbre {
        span {
          span {
            "<br />"
          }
        }
      }.to_s).to eq <<~HTML
        <span>
          <span>&lt;br /&gt;</span>
        </span>
      HTML
    end

    it "should escape the contents of attributes" do
      expect(arbre {
        span(class: "<br />")
      }.to_s).to eq <<~HTML
        <span class="&lt;br /&gt;"></span>
      HTML
    end

  end

end
