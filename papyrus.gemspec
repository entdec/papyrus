# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'papyrus/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = 'papyrus'
  spec.version = Papyrus::VERSION
  spec.authors = ['Tom de Grunt']
  spec.email = ['tom@degrunt.nl']
  spec.homepage = 'https://code.entropydecelerator.com/components/papyrus'
  spec.summary = 'Paperwork generation'
  spec.description = 'Paperwork generation in several output formats'
  spec.license = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.add_dependency 'barby', '~> 0.6'
  spec.add_dependency 'combine_pdf', '~> 1.0.23'
  spec.add_dependency 'decoro', '~> 0.1'
  spec.add_dependency 'img2zpl'
  spec.add_dependency 'labelary'
  spec.add_dependency 'liquidum'
  spec.add_dependency 'pg'
  spec.add_dependency 'prawn', '~> 2.4'
  spec.add_dependency 'prawn-svg', '~> 0.32'
  spec.add_dependency 'prawn-table', '~> 0.2'
  spec.add_dependency 'printnode', '~> 1.0'
  spec.add_dependency 'rails', '>= 6.0.2.1'
  spec.add_dependency 'rqrcode', '~> 1.2'
  spec.add_dependency 'servitium', '~> 1.1'
  spec.add_dependency 'state_machines-activerecord', '~> 0.9'
  spec.add_dependency 'tilt', '~> 2.0'

  spec.add_dependency 'importmap-rails'
  spec.add_dependency 'stimulus-rails'
  spec.add_dependency 'tailwindcss-rails'
  spec.add_dependency 'turbo-rails'

  spec.add_development_dependency 'auxilium', '~> 3'
  spec.add_development_dependency('pdf-inspector', '>= 1.2.1', '< 2.0.a')
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_development_dependency 'rubocop', '~> 1.4'
  spec.add_development_dependency 'ruby-lsp', '~> 0'
end
