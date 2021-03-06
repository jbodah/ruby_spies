$: << File.expand_path('../lib', __FILE__)
require 'spy/version'

Gem::Specification.new do |s|
  s.name        = 'spy_rb'
  s.version     = Spy::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'Test Spies for Ruby'
  s.description = "Mocking frameworks work by stubbing out functionality. Spy works by listening in on functionality and allowing it to run in the background. Spy is designed to be lightweight and work alongside Mocking frameworks instead of trying to replace them entirely."
  s.authors     = ['Josh Bodah']
  s.email       = 'jb3689@yahoo.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/jbodah/spy_rb'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
end
