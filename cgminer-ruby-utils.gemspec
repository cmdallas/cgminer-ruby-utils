# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'archon.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cgminer-ruby-utils'
  spec.version       = '0.1'
  spec.authors       = ['Chris Dallas']
  spec.email         = ['self@chrisdallas.tech']
  spec.description   = %q{Query cgminer API and send metrics to AWS CloudWatch}
  spec.summary       = %q{cgminer-ruby-utils}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'aws-sdk-cloudwatch'
  spec.add_development_dependency 'aws-sdk-ec2'
  spec.add_development_dependency 'cgminer/api'
  spec.add_development_dependency 'ipaddress'
end
