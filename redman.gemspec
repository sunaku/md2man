# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redman/version"
require "binman/gemspec"

Gem::Specification.new do |s|
  s.name        = "redman"
  s.version     = Redman::VERSION
  s.authors,
  s.email       = File.read('LICENSE').scan(/Copyright \d+ (.+) <(.+?)>/).transpose
  s.homepage    = "http://github.com/sunaku/redman"
  s.summary     = "UNIX man pages using Redcarpet2"
  s.description = nil

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "redcarpet", ">= 2.0.0b5", "< 3"
  s.add_development_dependency "minitest", ">= 2.7.0", "< 3"
end
