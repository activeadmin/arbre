# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "arbre/version"

Gem::Specification.new do |s|
  s.name        = "arbre"
  s.version     = Arbre::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Greg Bell"]
  s.email       = ["gregdbell@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{An Object Oriented DOM Tree in Ruby}
  s.description = %q{An Object Oriented DOM Tree in Ruby}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("activesupport", ">= 3.0.0")
end
