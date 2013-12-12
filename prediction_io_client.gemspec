# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prediction_io_client/version'

Gem::Specification.new do |spec|
  spec.name          = "prediction_io_client"
  spec.version       = FM::PredictionIO::VERSION
  spec.authors       = ["Joe Connor"]
  spec.email         = ["joe.connor@factorymedia.com"]
  spec.description   = %q{A more Ruby-ish REST client for Prediction.IO}
  spec.summary       = %q{A more Ruby-ish REST client for Prediction.IO}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  
  
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "faraday_middleware"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "activesupport"
end
