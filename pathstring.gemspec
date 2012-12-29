# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'pathstring/version'

Gem::Specification.new do |s|
  s.name          = "pathstring"
  s.version       = Pathstring::VERSION
  s.authors       = ["lacravate"]
  s.email         = ["lacravate@lacravate.fr"]
  s.homepage      = "https://github.com/lacravate/pathstring"
  s.summary       = "A Pathname / String midway interface, to files and directories"
  s.description   = "A Pathname / String midway interface, to files and directories"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'

  s.add_dependency 'pedlar'
  s.add_development_dependency 'rspec'
end
