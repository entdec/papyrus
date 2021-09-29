# frozen_string_literal: true

module Papyrus
  module Transactio
    extend ActiveSupport::Concern

    included do
      raise "#{name} must be papyrable" unless papyrable?

      orchestrator = Evento::Orchestrator.new(self)
      if papyrable_options[:life_cycle]
        orchestrator.define_event_methods_on(generator, life_cycle: true) do |object, options = {}|
        end
      end

      orchestrator = Evento::Orchestrator.new(self)
      orchestrator.after_transaction_log_commit(:papyrus) do |transaction_log_entry|
        resource = transaction_log_entry.transaction_loggable
        event = transaction_log_entry.event

        if resource.present? && event.present? && resource.papyrable?
          params = Papyrus.config.default_params(transaction_log_entry)

          Papyrus.event(event, resource, params)
          Papyrus.event('save', resource, params) if %w[create update].include?(event)
        end
      end
    end
  end
end
