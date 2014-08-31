# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'offsite_payments/integrations/smile_pay/version'

Gem::Specification.new do |spec|
  spec.name          = "offsite_payments-integrations-smile_pay"
  spec.version       = OffsitePayments::Integrations::SmilePay::VERSION
  spec.authors       = ["GoodLife", "lulalala"]
  spec.email         = ["mark@goodlife.tw"]
  spec.description   = %q{OffsitePayments for SmilePay 訊航科技, a Taiwan based payment gateway}
  spec.summary       = %q{OffsitePayments for SmilePay}
  spec.homepage      = "https://github.com/GoodLife/offsite_payments-integrations-smile_pay"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'offsite_payments', '~> 2.0', '>= 2.0.1'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency('test-unit', '~> 2.5.5')
  spec.add_development_dependency('mocha', '~> 0.13.0')
  spec.add_development_dependency('rails', '>= 3.2.14')
end
