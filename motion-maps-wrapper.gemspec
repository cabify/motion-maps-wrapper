# -*- encoding: utf-8 -*-
VERSION = "0.0.2"

Gem::Specification.new do |spec|
  spec.name          = "motion-maps-wrapper"
  spec.version       = VERSION
  spec.authors       = ["Mark Villacampa"]
  spec.email         = ["markvjal@gmail.com"]
  spec.description   = %q{Write a gem description}
  spec.summary       = %q{Write a gem summary}
  spec.homepage      = ""
  spec.license       = ""

  files = []
  files << 'README.md'
  files.concat(Dir.glob('lib/**/*.rb'))
  spec.files         = files
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "motion-stump"
end
