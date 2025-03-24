module Papyrus
  class GenerateJob < ApplicationJob
    def perform(event, obj = {}, params = {})

      ActiveRecord::Base.transaction do
        begin
          model = Papyrus::ObjectConverter.deserialize(obj)
          return unless model

          formatted_params = Papyrus::ObjectConverter.deserialize(params)
          generator = Papyrus::BaseGenerator.generator_for_obj(model).new(model, event, formatted_params)
          return unless generator.respond_to? event.to_sym
        rescue ActiveRecord::RecordNotFound => e
          Papyrus.logger&.error(e)
          return
        end

        generator.call
        templates = generator.templates
        generator.dispatch(templates) if templates.present?
      end
      cleanup_papyrus_events(obj, event)
    end

    def cleanup_papyrus_events(obj, event)
      papyrus_events = Papyrus::Event.where(
        transitionable_id: obj["id"],
        transitionable_type: obj["type"],
        transition_event: event.to_s
      )
      papyrus_events.destroy_all
    end

  end
end
