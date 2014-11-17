# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ebs_snapshots/version'

Gem::Specification.new do |spec|
  spec.name          = "ebs_snapshots"
  spec.version       = EbsSnapshots::VERSION
  spec.authors       = ["Michael Mell"]
  spec.email         = ["michael.mell@brightbytes.net"]
  spec.summary       = %q{ebs snapshotting tool .}
  spec.description   = %q{AWS base ebs snapshot tool.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"

  spec.add_dependency "aws-sdk-core"
  spec.add_dependency "bunny"
end
