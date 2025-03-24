module Papyrus
  module Concerns
    module EventsTransaction
      extend ActiveSupport::Concern

      included do
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

        after_commit do
          Papyrus::Event.all.each do |transition|
            transitionable = transition.transitionable_type.constantize.find(transition.transitionable_id)
            Papyrus.with_datastore(**transition.datastore) { Papyrus.event(transition.transition_event.to_sym, transitionable) }
          end
        end
      end
    end
  end
end
