# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "xmlish"
  s.version     = "0.0.1"
  s.authors     = ["Joel Plane"]
  s.email       = ["joel.plane@gmail.com"]
  s.homepage    = "https://github.com/joelplane/xmlish"
  s.summary     = %q{string interpolation from xml-like text}
  s.description = %q{small almost-xml parser for complex string interpolation}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
