# frozen_string_literal: true

module Papyrus
  module StateMachine
    extend ActiveSupport::Concern

    included do
      raise "#{name} must be papyrable" unless papyrable?

      state_machine.events.map(&:name)
                   .reject { |event_name| generator.method_defined?(event_name) }
                   .each do |event_name|
        generator.send(:define_method, event_name) { |object, options = {}| }
      end

      after_commit do
        Thread.current["___papyrus_state_machine_events"]&.each do |event|
          Papyrus.with_datastore (**event[:datastore]) { Papyrus.event(event[:event], event[:object]) }
        end
        # After events are fired we can clear the events
        Thread.current["___papyrus_state_machine_events"] = []
      end

      state_machine do
        # This records events within the same thread, and clears them in the same thread.
        # A different thread is a different transaction.
        after_transition any => any do |record, transition|
          ___record__papyrus_state_machine_event(transition.event, record)
          ___record__papyrus_state_machine_event(:update, record)
          ___record__papyrus_state_machine_event(:save, record)
        end

        def ___record__papyrus_state_machine_event(event, object)
          Thread.current["___papyrus_state_machine_events"] ||= []
          Thread.current["___papyrus_state_machine_events"] << {event: event, object: object, datastore: Papyrus.papyrus_datastore}
        end
      end
    end
  end
end
