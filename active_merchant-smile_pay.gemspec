# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_merchant/smile_pay/version'

Gem::Specification.new do |spec|
  spec.name          = "active_merchant-smile_pay"
  spec.version       = ActiveMerchant::SmilePay::VERSION
  spec.authors       = ["GoodLife", "lulalala"]
  spec.email         = ["mark@goodlife.tw"]
  spec.description   = %q{ActiveMerchant for SmilePay 訊航科技, a Taiwan based payment gateway}
  spec.summary       = %q{ActiveMerchant for SmilePay}
  spec.homepage      = "https://github.com/GoodLife/active_merchant-smile_pay"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency('activemerchant', '>= 1.32.1')
end
