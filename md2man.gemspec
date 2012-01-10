# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "md2man/version"

Gem::Specification.new do |s|
  s.name        = "md2man"
  s.version     = Md2Man::VERSION
  s.authors,
  s.email       = File.read('LICENSE').scan(/Copyright \d+ (.+) <(.+?)>/).transpose
  s.homepage    = "http://github.com/sunaku/md2man"
  s.summary     = "write UNIX man pages in Markdown"
  s.description = nil

  s.files         = `git ls-files`.split("\n") + Dir["man/**/*"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "binman", "~> 3"
  s.add_runtime_dependency "redcarpet", ">= 2.0.0b5", "< 3"
  s.add_development_dependency "minitest", ">= 2.7.0", "< 3"
end
