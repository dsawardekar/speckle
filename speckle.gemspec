lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'speckle/version'

Gem::Specification.new do |s|
  s.name     = 'speckle'
  s.version  = Speckle::VERSION
  s.authors  = ['Darshan Sawardekar']
  s.email    = 'darshan@sawardekar.org'
  s.homepage = "http://github.com/dsawardekar/speckle"
  s.license  = "MIT"

  s.description   = %q{Behaviour driven framework for testing vim scripts written in Riml}
  s.summary       = %q{Compiles *_spec.riml spec files into *.vim files and runs them inside vim}

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency 'riml', '~> 0.3.6'
  s.add_dependency 'rake', '~> 10.1.0'
  s.add_dependency 'bundler', '~> 1.3'

  s.add_development_dependency 'rspec-core', '~> 2.14.0'
  s.add_development_dependency 'rspec-expectations', '~> 2.14.0'
  s.add_development_dependency 'rspec-mocks', '~> 2.14.0'

end
