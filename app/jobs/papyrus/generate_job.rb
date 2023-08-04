module Papyrus
  class GenerateJob < ApplicationJob
    def perform(event, obj = {}, params = {})
      model = %w[obj_id obj_class].eql?(obj.keys) ? obj['obj_class'].safe_constantize&.find(obj['obj_id']) : obj
      return unless model

      generator = Papyrus::BaseGenerator.generator_for_obj(model).new(model, event, params)
      return unless generator.respond_to? event.to_sym

      generator.call
      templates = generator.templates

      generator.dispatch(templates) if templates.present?
    end
  end
end
