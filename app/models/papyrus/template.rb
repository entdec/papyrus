# frozen_string_literal: true

module Papyrus
  class Template < ApplicationRecord
    include Papyrus::Concerns::MetadataScoped

    begin
      has_many_attached :attachments
    rescue StandardError
      nil
    end

    def render(context, locale: I18n.locale)
      template = Tilt::PrawnTemplate.new(file_name, (metadata || {}).deep_symbolize_keys) { |_t| data }

      result = I18n.with_locale(locale) do
        template.render(Papyrus::Context.new(self), context)
      end

      StringIO.new(result)
    end

    def file_name
      description.gsub(/[^a-zA-Z0-9]/, '_').downcase + '.pdf'
    end

    def translation_scope
      scope = %w[]
      scope << description.underscore.gsub(/[^a-z]+/, '_') if description
      scope.join('.')
    end

    def previewable?
      persisted? && example_data.present?
    end
  end
end
