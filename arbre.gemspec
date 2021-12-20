# -*- encoding: utf-8 -*-
# frozen_string_literal: true
$:.push File.expand_path("../lib", __FILE__)
require "arbre/version"

Gem::Specification.new do |s|
  s.name        = "arbre"
  s.version     = Arbre::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Greg Bell"]
  s.email       = ["gregdbell@gmail.com"]
  s.homepage    = "https://github.com/activeadmin/arbre"
  s.summary     = %q{An Object Oriented DOM Tree in Ruby}
  s.description = %q{Arbre makes it easy to generate HTML directly in Ruby}
  s.license     = "MIT"

  s.files         = Dir['docs/**/*', 'lib/**/*', 'LICENSE'].reject { |f| File.directory?(f) }

  s.extra_rdoc_files = %w[CHANGELOG.md README.md]

  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.5'

  s.add_dependency("activesupport", ">= 3.0.0", "< 7.1")
  s.add_dependency("ruby2_keywords", ">= 0.0.2", "< 1.0")
end
