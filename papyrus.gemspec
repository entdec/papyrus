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
  spec.add_dependency 'pg'
  spec.add_dependency 'prawn', '~> 2.2'
  spec.add_dependency 'prawn-table', '~> 0.2'
  spec.add_dependency 'prawn-svg', '~> 0.29'
  spec.add_dependency 'rails', '~> 6.0.2', '>= 6.0.2.1'
  spec.add_dependency 'rqrcode', '~> 0.10'
  spec.add_dependency 'semacode-ruby19', '~> 0.7'
  spec.add_dependency 'tilt', '~> 2.0'

  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'rubocop', '~> 0'
end
