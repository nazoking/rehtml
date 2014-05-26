# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rehtml/version'
description = open(File.dirname(__FILE__)+"/README.md").read.gsub(/^.*\n(Pure Ruby)/m,'\1').gsub(/\n##.*/m,"")

Gem::Specification.new do |spec|
  spec.name          = "rehtml"
  spec.version       = REHTML::VERSION
  spec.authors       = ["nazoking"]
  spec.email         = ["nazoking@gmail.com"]
  spec.summary       = description.split(/\n/)[0].strip
  spec.description   = description
  spec.homepage      = "https://github.com/nazoking/rehtml"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
