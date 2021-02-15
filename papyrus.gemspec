# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'papyrus/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'papyrus'
  spec.version     = Papyrus::VERSION
  spec.authors     = ['Tom de Grunt']
  spec.email       = ['tom@degrunt.nl']
  spec.homepage    = 'https://code.entropydecelerator.com/components/papyrus'
  spec.summary     = 'Paperwork generation'
  spec.description = 'Paperwork generation in several output formats'
  spec.license     = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'barby', '~> 0.6'
  spec.add_dependency 'decoro', '~> 0.1'
  spec.add_dependency 'evento', '~> 0.1' # This is our own gem, you must add it to your project's Gemfile for this to work
  spec.add_dependency 'liquor'
  spec.add_dependency 'pg'
  spec.add_dependency 'prawn', '~> 2.2'
  spec.add_dependency 'prawn-svg', '~> 0.29'
  spec.add_dependency 'prawn-table', '~> 0.2'
  spec.add_dependency 'rails', '~> 6.0', '>= 6.0.2.1'
  spec.add_dependency 'rqrcode', '~> 0.10'
  spec.add_dependency 'servitium', '~> 1.1'
  spec.add_dependency 'tilt', '~> 2.0'

  spec.add_development_dependency 'auxilium', '~> 0.2'
  spec.add_development_dependency('pdf-inspector', '>= 1.2.1', '< 2.0.a')
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'rubocop', '~> 0'
end
