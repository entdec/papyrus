# frozen_string_literal: true

module Papyrus
  class InitializeForClassService < ApplicationService
    transactional false

    attr_reader :klass, :name, :options

    def initialize(klass, options = {})
      super()
      @klass = klass
      @name = klass.name
      @options = options
    end

    def perform
      unless generator
        raise "Papyrus Generator missing for class #{name}, please create a #{Papyrus::Generator.generator_name_for_class(name)}"
      end

      add_to_config
      orchestrator = Evento::Orchestrator.new(klass)
      orchestrator.define_event_methods_on(generator,
                                           state_machine: options[:use_state_machine], life_cycle: options[:life_cycle]) do |object, params = {}|
      end

      if options[:use_state_machine]
        orchestrator.after_audit_trail_commit(:papyrus) do |resource_state_transition|
          resource = resource_state_transition.resource
          Papyrus.with(resource).generate(event.to_s) if resource.papyrable?
        end
      end

      orchestrator.after_transaction_log_commit(:papyrus) do |transaction_log_entry|
        record  = transaction_log_entry.transaction_loggable
        event   = transaction_log_entry.event
        Papyrus.with(record).generate(event.to_s) if record.papyrable? && event.present?
        Papyrus.with(record).generate('save') if %w[create update].include?(event) && record.papyrable?
      end
    end

    private

    def add_to_config
      Papyrus.config.add_papyrable_class(klass)
    end

    def generator
      Papyrus::Generator.generator_for_class(name)
    end
  end
end
