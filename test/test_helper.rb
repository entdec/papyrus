# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require_relative '../test/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require 'minitest/mock'
require 'rails/test_help'
require 'pdf/inspector'
# Filter out the backtrace from minitest while preserving the one from other libraries.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
ActiveSupport::TestCase.fixture_paths = [File.expand_path('fixtures', __dir__)]
ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
ActiveSupport::TestCase.file_fixture_path = File.expand_path('fixtures/files', __dir__)
ActiveSupport::TestCase.fixtures :all

# frozen_string_literal: true

class ApplicationTestCase < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  fixtures :all
end
