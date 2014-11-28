# Arbre - HTML Views in Ruby

Arbre makes it easy to generate HTML directly in Ruby. This gem was extracted from [Active Admin](https://github.com/activeadmin/active_admin).

[![Version  ](http://img.shields.io/gem/v/arbre.svg)                    ](https://rubygems.org/gems/arbre)
[![Travis CI](http://img.shields.io/travis/activeadmin/arbre/master.svg)](https://travis-ci.org/activeadmin/arbre)

## Simple Usage

```ruby
html = Arbre::Context.new do
  h2 "Why is Arbre awesome?"

  ul do
    li "The DOM is implemented in ruby"
    li "You can create object oriented views"
    li "Templates suck"
  end
end

puts html.to_s # =>
```

```html
<h2>Why is Arbre awesome?</h2>
<ul>
  <li>The DOM is implemented in ruby</li>
  <li>You can create object oriented views</li>
  <li>Templates suck</li>
</ul>
```

## The DOM in Ruby

The purpose of Arbre is to leave the view as ruby objects as long
as possible. This allows OO Design to be used to implement the view layer.

```ruby
html = Arbre::Context.new do
  h2 "Why Arbre is awesome?"
end

html.children.size # => 1
html.children.first # => #<Arbre::HTML::H2>
```

## Components

The purpose of Arbre is to be able to create shareable and extendable HTML
components. To do this, you create a subclass of Arbre::Component.

For example:

```ruby
class Panel < Arbre::Component
  builder_method :panel

  def build(title, attributes = {})
    super(attributes)

    h3(title, class: "panel-title")
  end
end
```

The builder_method defines the method that will be called to build this component
when using the DSL. The arguments passed into the builder_method will be passed 
into the #build method for you.

You can now use this panel in any Arbre context:

```ruby
html = Arbre::Context.new do
  panel "Hello World", id: "my-panel" do
    span "Inside the panel"
  end
end

puts html.to_s # =>
```

```html
<div class='panel' id="my-panel">
  <h3 class='panel-title'>Hello World</h3>
  <span>Inside the panel</span>
</div>
```      
      
### Text Nodes

To insert unwrapped text nodes use `text_node`:

```ruby
html = Arbre::Context.new do
  panel "Hello World", id: "my-panel" do
    span "Inside the panel"
    text_node "Plain text"
  end
end

puts html.to_s # =>
```

```html
<div class='panel' id="my-panel">
  <h3 class='panel-title'>Hello World</h3>
  <span>Inside the panel</span>
  Plain text
</div>
```
