# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'md2man/version'

Gem::Specification.new do |s|
  s.name          = 'md2man'
  s.version       = Md2Man::VERSION
  s.authors,
  s.email         = File.read('LICENSE').scan(/Copyright \d+ (.+) <(.+?)>/).transpose
  s.homepage      = 'http://github.com/sunaku/md2man'
  s.summary       = 'markdown to manpage'
  s.description   = 'Converts markdown documents into UNIX manual pages.'

  s.files         = `git ls-files`.split("\n") + Dir['man/man?/*.?']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'binman', '~> 3.0'
  s.add_runtime_dependency 'redcarpet', '~> 2.1'
  s.add_development_dependency 'minitest', '~> 4.0'
  s.add_development_dependency 'rake', '~> 0.9.2.2'
end
