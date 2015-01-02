# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arr/version'

Gem::Specification.new do |spec|
  spec.name          = "arr"
  spec.version       = Arr::VERSION
  spec.authors       = ["Josep Arús"]
  spec.email         = ["josep@joseparus.com"]
  spec.summary       = %q{An different way to work with R in Ruby}
  spec.description   = %q{An different way to work with R in Ruby}
  spec.homepage      = "http://www.github.com/undeadpixel/arr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  
  # TESTING
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "guard-rspec", "~> 4.5"
end
