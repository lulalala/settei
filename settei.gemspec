lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "settei/version"

Gem::Specification.new do |spec|
  spec.name          = "settei"
  spec.version       = Settei::VERSION
  spec.authors       = ["lulalala"]
  spec.email         = ["mark@goodlife.tw"]

  spec.summary       = %q{Hash based configuration}
  spec.description   = %q{Hash based configuration with flexibility and 12-factor app deployment in mind. Settei allows use of nested hash, and can be serialized as environment variable, suitable for 12-factor app.}
  spec.homepage      = "https://github.com/lulalala/settei"
  spec.licenses      = ['MIT']

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.7.0"
  spec.add_development_dependency "rails"
end
