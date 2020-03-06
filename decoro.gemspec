# frozen_string_literal: true

require_relative 'lib/decoro/version'

Gem::Specification.new do |spec|
  spec.name          = 'decoro'
  spec.version       = Decoro::VERSION
  spec.authors       = ['Tom de Grunt']
  spec.email         = ['tom@degrunt.nl']

  spec.summary       = 'Decorators'
  spec.description   = 'Simple and effective decorators'
  spec.homepage = 'https://code.entropydecelerator.com/components/decoro'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://code.entropydecelerator.com/components/decoro'
  spec.metadata['changelog_uri'] = 'https://code.entropydecelerator.com/components/decoro'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.add_development_dependency 'rubocop', '~> 0.80'
  spec.add_development_dependency 'solargraph', '~> 0.38'

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
