# frozen_string_literal: true

module Papyrus
  module StateMachine
    extend ActiveSupport::Concern

    included do
      raise "#{name} must be papyrable" unless papyrable?

      orchestrator = Evento::Orchestrator.new(self)
      orchestrator.define_event_methods_on(generator, state_machine: true) { |object, options = {}| }

      orchestrator.after_audit_trail_commit(:papyrus) do |resource_state_transition|
        resource = resource_state_transition.resource
        Papyrus.event(event, resource) if resource.papyrable? && event.present?
      end
    end
  end
end
