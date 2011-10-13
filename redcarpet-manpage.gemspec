# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redcarpet-manpage/version"

Gem::Specification.new do |s|
  s.name        = "redcarpet-manpage"
  s.version     = RedcarpetManpage::VERSION
  s.authors,
  s.email       = File.read('LICENSE').scan(/Copyright \d+ (.+) <(.+?)>/).transpose
  s.homepage    = "http://github.com/sunaku/redcarpet-manpage"
  s.summary     = "UNIX man page renderer for Redcarpet2"
  s.description = nil

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "redcarpet", ">= 2.0.0b5"
end
