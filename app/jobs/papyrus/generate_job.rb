module Papyrus
  class GenerateJob < ApplicationJob
    after_perform :cleanup_papyrus_events
    def perform(event, obj = {}, params = {})
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

    def cleanup_papyrus_events
      event = arguments.first
      obj = arguments.second

      papyrus_events = Papyrus::Event.where(
        transitionable: obj,
        transition_event: event.to_s
      )
      papyrus_events.destroy_all
    end

  end
end
