# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'challah/version'

Gem::Specification.new do |s|
  s.name          = "challah"
  s.version       = Challah::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["John Tornow"]
  s.email         = ["john@johntornow.com"]
  s.homepage      = "http://github.com/jdtornow/challah"
  s.summary       = "Simple authentication and authorization gem for Rails."
  s.description   = %Q{A simple Rails engine gem for authentication, authorization, users, roles and permissions.}
  s.files         = Dir.glob("{app,config,db,test,lib,vendor}/**/*") + %w(README.md CHANGELOG.md)
  s.require_paths = ["lib"]

  s.add_dependency 'highline'
  s.add_dependency 'rails', '>= 3.1'
  s.add_dependency 'rake', '>= 0.9.2'
  s.add_dependency 'bcrypt-ruby', '>= 0'

  s.required_ruby_version     = Gem::Requirement.new('>= 1.9.2')
end