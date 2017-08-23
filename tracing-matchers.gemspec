# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tracing/matchers/version"

Gem::Specification.new do |spec|
  spec.name          = "tracing-matchers"
  spec.version       = Tracing::Matchers::VERSION
  spec.authors       = ["iaintshine"]
  spec.email         = ["bodziomista@gmail.com"]

  spec.summary       = %q{RSpec matchers for testing mocked OpenTracing instrumentations}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/iaintshine/ruby-tracing-matchers"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "test-tracer", "~> 1.1"
  spec.add_dependency "rspec", ">= 2.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
end
