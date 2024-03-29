# frozen_string_literal: true

module Papyrus
  # Generators select templates, can manipulate them and
  class BaseGenerator
    include ActiveSupport::Callbacks

    delegate :liquid_variable_name_for, :class_name_for, :class_names_for, :event_name_for, to: :class

    define_callbacks :action, terminator: ->(_target, result_lambda) { result_lambda.call == false }

    attr_reader :templates, :attachments, :event, :object, :params

    def initialize(object, event, params = {})
      @object = object
      @event = event
      @params = params
    end

    # Calls the event method on the generator
    def call
      select_templates
      run_callbacks(:action) do
        send(@event.to_sym, @object, @params)
      end
    end

    # Turns the templates in papers, and generates the papers
    def dispatch(filtered_templates)
      filtered_templates.map do |template|
        template.generate(@object, liquid_context, params)
      end
    end

    class << self
      #
      # Returns the variable name used in the liquid context
      #
      # @param [Object] obj Any object with a backing drop
      #
      # @return [String] underscored, lowercase string
      #
      def liquid_variable_name_for(obj)
        return obj.keys.first.to_s if obj.is_a?(Hash)

        plural = obj.is_a?(Array) || obj.is_a?(ActiveRecord::Relation)
        list = plural ? obj : [obj]
        klass = list.first.class
        klass = klass.base_class if klass.respond_to?(:base_class)
        name = klass.name.demodulize
        name = name.pluralize if plural
        name.underscore
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

      def event_name_for(obj, event)
        if obj.is_a?(Hash)
          "#{obj.keys.first}##{event}"
        else
          event
        end
      end

      def generator_for_class(name)
        return unless name

        klass = generator_name_for_class(name).safe_constantize
        klass ||= generator_for_class(name.safe_constantize&.superclass&.name)
        klass ||= generator_for_class(name.safe_constantize&.superclass&.superclass&.name)
        klass
      end

      def generator_name_for_class(name)
        "#{name}Generator"
      end

      def generator_for_obj(obj)
        return Papyrus::CustomGenerator if obj.is_a? Hash

        klass = generator_name_for_obj(obj).safe_constantize

        # Lets check 2 levels above to see if a messager exists for a possible super class (think STI)
        klass ||= generator_name_for_obj(obj.class.superclass).safe_constantize
        klass ||= generator_name_for_obj(obj.class.superclass.superclass).safe_constantize

        raise Papyrus::MissingGeneratorException.new(self), "generator missing for #{obj.class.name}" unless klass

        klass
      end

      def generator_name_for_obj(obj)
        "#{class_name_for(obj)}Generator"
      end

      def locale(locale = nil)
        @locale = locale if locale
        @locale
      end

      def template_scope(template_scope = nil)
        @template_scope = template_scope if template_scope
        @template_scope
      end
    end

    private

    # Returns the relevant templates for the object / event combination
    def select_templates
      return @templates if @templates

      @templates = Template.unscoped.where(klass: class_names_for(@object),
                                           event: event_name_for(@object, @event)).where(enabled: true)
      @templates = @templates.instance_exec(@object, &Papyrus.config.default_template_scope)

      # Filter applicable templates
      @templates = @templates.where(id: @templates.select do |t|
                                          t.applicable?(@object, liquid_context, params)
                                        end.map(&:id))

      # See if we need to do something additional
      template_scope_proc = self.class.template_scope
      @templates = @templates.instance_exec(@object, &template_scope_proc) if template_scope_proc

      # Filter templates by id, for reprocess
      if @params.dig('options', 'template_id').present?
        @templates = @templates.select do |t|
          t.id == @params.dig('options', 'template_id')
        end
      end

      @templates
    end

    def liquid_context
      assigns = @params || {}
      instance_variables.reject do |i|
        %w[@params @object @locale @templates @template_scope].include? i.to_s
      end.each do |i|
        assigns[i.to_s[1..-1]] = instance_variable_get(i)
      end

      context = { liquid_variable_name_for(@object) => (@object.is_a?(Hash) ? @object[@object.keys.first].deep_stringify_keys : @object.to_liquid) }
      assigns.merge(context)
    end
  end
end
