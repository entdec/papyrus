# frozen_string_literal: true

module Papyrus
  class Template < ApplicationRecord
    KINDS = [%w[PDF pdf], %w[Liquid liquid]].freeze

    has_many :papers
    has_many_attached :attachments

    include Papyrus::Concerns::MetadataScoped

    def generate(context, object: nil, locale: I18n.locale)
      data = render(context.reject { |h| h == 'pdf' }, locale: locale)
      paper = Paper.create(template: self, data: context.reject { |h| h == 'pdf' }, papyrable: object)
      paper.attachment.attach(io: data, filename: file_name, content_type: 'application/pdf')
      data.rewind

      [paper, data]
    end

    def render(context, locale: I18n.locale)
      template = Tilt::PrawnTemplate.new(file_name, (metadata || {}).deep_symbolize_keys) { |_t| data }

      result = I18n.with_locale(locale) do
        template.render(Papyrus::Context.new(self), context)
      end

      StringIO.new(result)
    end

    def file_name
      "#{description.gsub(/[^a-zA-Z0-9]/, '_').downcase}.pdf"
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
