---
redirect_from: /docs/documentation.html
---
# Arbre
HTML Views in Ruby

### Introduction

Arbre is a alternate template system for [Ruby on Rails Action View](http://guides.rubyonrails.org/action_view_overview.html).
Arbre expresses HTML using a Ruby DSL, which makes it similar to the [Builder](https://github.com/tenderlove/builder) gem for XML.
Arbre was extracted from [Active Admin](https://activeadmin.info/).

An example `index.html.arb`:

```ruby
html {
  head {
    title "Welcome page"
  }
  body {
    para "Hello, world"
  }
}
```

The purpose of Arbre is to leave the view as Ruby objects as long as possible,
which allows an object-oriented approach including inheritance, composition, and encapsulation.

### Installation

Add gem `arbre` to your `Gemfile` and `bundle install`.

Arbre registers itself as a Rails template handler for files with an extension `.arb`.

### Tags

Arbre DSL is composed of HTML tags.  Tag attributes including `id` and HTML classes are passed as a hash parameter and the tag body is passed as a block. Most HTML5 tags are implemented, including `script`, `embed` and `video`.

A special case is the paragraph tag, <p>, which is mapped to `para`.

JavaScript can be included by using `script { raw ... }`

To include text that is not immediately part of a tag use `text_node`.

### Components

Arbre DSL can be extended by defining new tags composed of other, simpler tags.
This provides a simpler alternative to nesting partials.
The recommended approach is to subclass Arbre::Component and implement a new builder method.

The builder_method defines the method that will be called to build this component
when using the DSL. The arguments passed into the builder_method will be passed 
into the #build method for you.

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

By default components are `div` tags with an HTML class corresponding to the component class name.  This can be overridden by redefining the `tag_name` method.

Several examples of Arbre components are [included in Active Admin](https://activeadmin.info/12-arbre-components.html)

### Contexts

An [Arbre::Context](http://www.rubydoc.info/gems/arbre/Arbre/Context) is an object in which Arbre DSL is interpreted, providing a root for the Ruby DOM that can be [searched and manipulated](http://www.rubydoc.info/gems/arbre/Arbre/Element). A context is automatically provided when a `.arb` template or partial is loaded. Contexts can be used when developing or testing a component.  Contexts are rendered by calling to_s.

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

A context allows you to specify Rails template assigns, aka. 'locals' and helper methods. Templates loaded by Action View have access to all [Action View helper methods](http://guides.rubyonrails.org/action_view_overview.html#overview-of-helpers-provided-by-action-view)

### Background

Similar projects include:
- [Markaby](http://markaby.github.io/), written by \_why the luck stiff.
- [Erector](http://erector.github.io/), developed at PivotalLabs.
- [Fortitude](https://github.com/ageweke/fortitude), developed at Scribd.
- [Inesita](https://inesita.fazibear.me/) (Opal)
- [html_builder](https://github.com/crystal-lang/html_builder) (Crystal)

