# frozen_string_literal: true

module Papyrus
  class Configuration
    attr_accessor :admin_authentication_module, :base_controller, :visible_scope, :add_metadata,
                  :metadata_fields # , :allow_custom_events,
    attr_writer :logger, :host, :metadata_humanize

    def initialize
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @base_controller = '::ApplicationController'
      @visible_scope = -> { all }
      @add_metadata = -> {}
      @metadata_fields = {}
      @metadata_humanize = ->(data) { data.inspect }

      # Disabled for now - not using it
      # @allow_custom_events = false
      @papyrable_classes = []
      @papyrable_class_names = []
    end

    # logger [Object].
    def logger
      @logger.is_a?(Proc) ? instance_exec(&@logger) : @logger
    end

    # Make the part that is important for visible readable for humans
    def metadata_humanize(metadata)
      @metadata_humanize.is_a?(Proc) ? instance_exec(metadata, &@metadata_humanize) : @metadata_humanize
    end

    def add_papyrable_class(klass)
      @papyrable_class_names = []
      @papyrable_classes << klass.to_s unless @papyrable_classes.include?(klass.to_s)
    end

    def papyrable_class_names
      return @papyrable_class_names if @papyrable_class_names.present?

      compile_papyrable_class_names!
    end

    private

    def compile_papyrable_class_names
      names = []
      # names << 'Custom' if allow_custom_events

      @papyrable_classes.each do |klass_name|
        klass = klass_name.constantize
        names << klass.name
        names += klass.descendants.map(&:name)
      end

      names.sort!
    end

    def compile_papyrable_class_names!
      @papyrable_class_names = compile_papyrable_class_names
    end
  end
end
