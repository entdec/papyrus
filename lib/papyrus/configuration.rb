# frozen_string_literal: true

module Nuntius
  class Configuration
    attr_accessor :admin_authentication_module
    attr_accessor :base_controller
    attr_writer   :logger
    attr_writer   :host
    attr_writer   :metadata_humanize

    attr_accessor :visible_scope
    attr_accessor :add_metadata
    attr_accessor :metadata_fields

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @base_controller = '::ApplicationController'
      @visible_scope = -> { all }
      @add_metadata = -> {}
      @metadata_fields = {}
      @metadata_humanize = ->(data) { data.inspect }
    end

    # logger [Object].
    def logger
      @logger.is_a?(Proc) ? instance_exec(&@logger) : @logger
    end

    # Make the part that is important for visible readable for humans
    def metadata_humanize(metadata)
      @metadata_humanize.is_a?(Proc) ? instance_exec(metadata, &@metadata_humanize) : @metadata_humanize
    end
  end
end
