
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_bigtable_client/version"

Gem::Specification.new do |spec|
  spec.name          = "simple_bigtable_client"
  spec.version       = SimpleBigtableClient::VERSION
  spec.authors       = ["Fonsan"]
  spec.email         = ["fonsan@gmail.com"]

  spec.summary       = %q{A simple abstraction of reading and writing to bigtable}
  spec.description   = %q{A simple abstraction of reading and writing to bigtable}
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "google-cloud-bigtable", "0.1.3"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
