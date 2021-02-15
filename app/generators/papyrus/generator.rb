# frozen_string_literal: true

module Papyrus
  class Generator
    def initialize(object, event, options = {})
      if self.class.generator_for_class(object.class) != self.class
        raise(Papyrus::Error, "This generator does not handle #{object.class} objects")
      end

      unless self.class.public_instance_methods(false).include?(event.to_sym)
        raise(Vorto::Error, "The #{event} event has not been implemented")
      end

      @object  = object
      @event   = event
      @options = options
    end

    def call
      return if flows.count.zero?

      public_send(@event, @object, @options)

      # envelope = { content_type: 'application/json' }
      # payload  = @object.to_vorto if @object.respond_to?(:to_vorto)
      # payload  ||= @object.as_json({ root: true }.merge(@options[:payload_options] || {})).to_json

      flows.each do |flow|
        next unless process_flow?(@object, flow)

        # generate paper from template
        # Vorto.create_message(flow, envelope, payload, messagable: @object)
      end
    end

    def templates
      return @templates if @templates

      @templates = Vorto::Flow.for_event(@object.class, @event).enabled
      # flow_scope = self.class.flow_scope
      # @flows     = flows.instance_exec(@object, &flow_scope) if flow_scope
      @flows
    end

    def process_flow?(_object, _flow)
      true
    end

    class << self
      def create(object, event, options = {})
        generator_class = generator_for_class(object.class)
        raise(Vorto::Error, "There is no generator for #{object.class}") if generator_class.nil?

        generator_class.new(object, event, options)
      end

      def handles?(object, event)
        generator_class = generator_for_class(object.class)
        return false unless generator_class.present?

        generator_class.public_instance_methods(false).include?(event.to_sym)
      end

      def flow_scope(flow_scope = nil)
        @flow_scope = flow_scope if flow_scope
        @flow_scope
      end

      def generator_name_for_class(klass)
        "#{klass}Generator"
      end

      def generator_for_class(klass)
        klass_name = klass.to_s
        klass      = klass_name.constantize
        generator = generator_name_for_class(klass_name).safe_constantize
        return generator if generator.present?

        generator_for_class(klass.superclass) if klass.superclass.present?
      end
    end
  end
end
