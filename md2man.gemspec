# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'md2man/version'

Gem::Specification.new do |s|
  s.name          = 'md2man'
  s.version       = Md2Man::VERSION
  s.authors,
  s.email         = File.read('LICENSE').scan(/Copyright \d+ (.+) <(.+?)>/).transpose
  s.license       = 'ISC'
  s.homepage      = 'https://sunaku.github.io/md2man'
  s.summary       = 'markdown to manpage'
  s.description   = 'Converts markdown into UNIX manpages and HTML webpages.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.files += Dir['man/man?/*.?']         # UNIX manpages
  s.files += Dir['man/**/*.{html,css}']  # HTML manpages

  s.required_ruby_version = '>= 1.9.1'
  s.add_runtime_dependency 'binman', '~> 5.0'
  s.add_runtime_dependency 'redcarpet', '~> 3.0'
  s.add_runtime_dependency 'rouge', '~> 3.0'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake', '~> 12.0'
end
