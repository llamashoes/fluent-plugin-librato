# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-librato"
  spec.version       = "0.0.1"
  spec.authors       = ["kiyoto"]
  spec.email         = ["kiyoto@treasure-data.com"]
  spec.summary       = %q{Fluentd plugin to post data to Librato Metrics}
  spec.homepage      = "https://github.com/kiyoto/fluent-plugin-librato"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test_unit"

  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "librato-metrics"
end
