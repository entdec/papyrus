# frozen_string_literal: true

namespace :papyrus do
  desc 'Release a new version'
  task :release do
    version_file = './lib/papyrus/version.rb'
    File.open(version_file, 'w') do |file|
      file.puts <<~EOVERSION
        # frozen_string_literal: true

        module Papyrus
          VERSION = '#{Papyrus::VERSION.split('.').map(&:to_i).tap { |parts| parts[2] += 1 }.join('.')}'
        end
      EOVERSION
    end
    module Papyrus
      remove_const :VERSION
    end
    load version_file
    puts "Updated version to #{Papyrus::VERSION}"

    # spec = Gem::Specification.find_by_name('papyrus')
    # spec.version = Papyrus::VERSION

    `git commit lib/papyrus/version.rb -m "Version #{Papyrus::VERSION}"`
    `git push`
    `git tag #{Papyrus::VERSION}`
    `git push --tags`
  end
end
