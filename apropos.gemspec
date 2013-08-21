# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apropos/version'

Gem::Specification.new do |spec|
  spec.name          = "apropos"
  spec.version       = Apropos::VERSION
  spec.authors       = ["Gabriel Gilder"]
  spec.email         = ["gabriel@squareup.com"]
  spec.description   = %q{Apropos helps your site serve up the appropriate image for every visitor. Serving multiple versions of an image in responsive and/or localized web sites can be a chore, but Apropos simplifies and automates this task. Instead of manually writing a lot of CSS rules to swap different images, Apropos generates CSS for you based on a simple file naming convention.}
  spec.summary       = %q{Apropos helps your site serve up the appropriate image for every visitor.}
  spec.homepage      = "https://github.com/square/apropos"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "compass"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.13"
  spec.add_development_dependency "cane"
  spec.add_development_dependency "simplecov"
end
