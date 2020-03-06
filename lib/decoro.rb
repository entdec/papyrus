# frozen_string_literal: true

require 'decoro/version'
require 'decoro/base'
require 'decoro/helpers'
require 'decoro/railtie' if defined?(Rails)

module Decoro
  class Error < StandardError; end
  # Your code goes here...
end
