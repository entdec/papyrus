module Papyrus
  class GenerateJob < ApplicationJob
    def perform(event, obj = {}, params = {})
      model = Papyrus::FormatParams.new(obj).deserialize
      return unless model

      formatted_params = Papyrus::FormatParams.new(params).deserialize

      generator = Papyrus::BaseGenerator.generator_for_obj(model).new(model, event, formatted_params)
      return unless generator.respond_to? event.to_sym

      generator.call
      templates = generator.templates

      generator.dispatch(templates) if templates.present?
    end
  end
end
