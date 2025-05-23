module Papyrus
  module Concerns
    module EventsTransaction
      extend ActiveSupport::Concern

      included do
        raise "#{name} must be papyrable" unless papyrable?

        state_machine.events.map(&:name)
                     .reject { |event_name| generator.method_defined?(event_name) }
                     .each do |event_name|
          generator.send(:define_method, event_name) { |object, options = {}| }
        end

        state_machine do
          after_transition any => any do |record, transition|
            event = Papyrus::Event.find_or_initialize_by(
              transitionable_id: record.id,
              transitionable_type: record.class.to_s,
              transition_event: transition.event.to_s,
              transition_attribute: transition.attribute.to_s
            )
            event.update!(
              transition_from: transition.from.to_s,
              transition_to: transition.to.to_s,
              datastore: Papyrus.papyrus_datastore.deep_dup
            )
          end
        end

        after_commit :dispatch_papyrus_event
      end
      def dispatch_papyrus_event
        self.class.transaction do
          events = Papyrus::Event.where(
            transitionable_type: self.class.to_s,
            transitionable_id: self.id
          ).lock("FOR UPDATE OF papyrus_events SKIP LOCKED")
          events.find_each do |transition|
            begin
              Papyrus.with_datastore(**transition.datastore) { Papyrus.event(transition.transition_event.to_sym, transition.transitionable) }
              transition.destroy!
            rescue => e
              Rails.logger.error("Failed to dispatch papyrus event #{transition.id}: #{e.message}")
            end
          end
        end
      end

    end
  end
end
