# frozen_string_literal: true

module Papyrus
  class Template < ApplicationRecord
    include Papyrus::Concerns::MetadataScoped

    def render(context)
      template = Tilt::PrawnTemplate.new(metadata.deep_symbolize_keys) { |_t| data }
      template.render(Papyrus::Context.new(self), data: context)
    end

    def file_name
      description.gsub(/[^a-zA-Z0-9]/, '_').downcase + '.pdf'
    end

    def translation_scope
      scope = %w[]
      scope << description.underscore.gsub(/[^a-z]+/, '_') if description
      scope.join('.')
    end
  end
end
