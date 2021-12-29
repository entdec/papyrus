module Papyrus
  class GenerateJob < ApplicationJob
    def perform(obj, event, params = {})
      return unless obj

      generator = Papyrus::BaseGenerator.generator_for_obj(obj).new(obj, event, params)
      return unless generator.respond_to? event.to_sym

      generator.call
      templates = generator.templates

      generator.dispatch(templates) if templates.present?
    end
  end
end
