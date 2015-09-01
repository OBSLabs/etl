# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'etl/version'

Gem::Specification.new do |spec|
  spec.name          = "etl"
  spec.version       = Etl::VERSION
  spec.authors       = ["Alexander Petrov"]
  spec.email         = ["apetrov@virool.com"]
  spec.summary       = %q{Extract Transform Load toolkit}
  spec.description   = %q{A DSL to define ETL workflow with ruby}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "> 0.8.6"
  spec.add_development_dependency "rspec"
end
