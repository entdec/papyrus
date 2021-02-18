# frozen_string_literal: true

module Papyrus
  class Generator
    delegate :class_names_for, to: :class

    include ActiveSupport::Callbacks
    define_callbacks :action, terminator: ->(_target, result_lambda) { result_lambda.call == false }

    def initialize(object, event, options = {}, context = nil)
      if self.class.generator_for_class(object.class) != self.class
        raise(Papyrus::Error, "This generator does not handle #{object.class} objects")
      end

      unless self.class.public_instance_methods(false).include?(event.to_sym)
        raise(Papyrus::Error, "The #{event} event has not been implemented")
      end

      @object  = object
      @event   = event
      @options = options
      @context = context
    end

    def call
      return if templates.count.zero?

      @context = @object.to_papyrus if @object.respond_to?(:to_papyrus)
      @context ||= @object.as_json({ root: false }.merge(@options[:payload_options] || {}))
      @context = @context.reject do |h|
        h == 'pdf'
      end

      run_callbacks(:action) do
        public_send(@event.to_sym, @object, @options, @context)
      end

      Papyrus::GenerateJob.perform_later(@object, @event.to_s, @options, @context)
    end

    def generate
      templates.map do |template|
        paper, = template.generate(@context, locale: @context[:locale], object: @object, owner: @options[:owner])
        paper.print!
      end
    end

    def templates
      return @templates if @templates

      @templates = Papyrus::Template.where(klass: class_names_for(@object), event: @event)
      @templates
    end

    class << self
      def create(object, event, options = {}, context = nil)
        generator_class = generator_for_class(object.class)
        raise(Papyrus::Error, "There is no generator for #{object.class}") if generator_class.nil?

        generator_class.new(object, event, options, context)
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

      def class_name_for(obj)
        if obj.is_a?(Array) || obj.is_a?(ActiveRecord::Relation)
          obj.first.class.name.demodulize
        elsif obj.is_a?(Hash)
          'Custom'
        elsif obj.is_a?(Class)
          obj.name.demodulize
        else
          obj.class.name
        end
      end

      def class_names_for(obj)
        main_class_name = class_name_for(obj)

        return [main_class_name] if !obj.class.respond_to?(:base_class?) || obj.class.base_class?

        list = [main_class_name]
        list << obj.class.base_class.name
        list
      end
    end
  end
end
