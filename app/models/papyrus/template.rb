module Papyrus
  class Template < ApplicationRecord
    KINDS = [%w[PDF pdf], %w[Liquid liquid]].freeze

    has_many :papers
    has_many_attached :attachments

    scope :enabled, -> { where(enabled: true) }

    include Papyrus::Concerns::MetadataScoped

    def generate(object, context, params)
      locale = params[:locale] || I18n.locale
      owner = params[:owner]
      consolidation_id = params[:consolidation_id]

      begin
        data = render(context.reject { |h| h == 'pdf' }, locale: locale)
      rescue StandardError => e
        data = if paper_kind == 'pdf'
                 render({}, locale: locale, data_override: %(pdf.text "#{e.message.dup}\n#{e.backtrace.join("\n")}"))
               else
                 StringIO.new e.message.dup + "\n" + e.backtrace.join("\n")
               end
      end

      paper = Paper.new(template: self,
                        kind: paper_kind,
                        papyrable: object.is_a?(Hash) ? nil : object,
                        owner: owner,
                        use: use,
                        purpose: purpose,
                        consolidation_id: consolidation_id)
      paper.attachment.attach(io: data,
                              filename: file_name(context),
                              content_type: (kind == 'pdf' ? 'application/pdf' : 'application/octet-stream'),
                              identify: false)

      paper.save!
      data.rewind

      [paper, data]
    end

    def render(context, locale: I18n.locale, data_override: data)
      result = I18n.with_locale(locale) do
        if kind == 'pdf'
          template = Tilt::PrawnTemplate.new(file_name(context), (metadata || {}).deep_symbolize_keys) { |_t| data_override }
          template.render(Papyrus::Context.new(self), Shash.new(context.merge(locale: locale)))
        else
          ::Liquidum.render(data,
                            { assigns: context.merge('template' => self, locale: locale),
                              registers: { 'template' => self } })
        end
      end

      StringIO.new(result)
    end

    def applicable?(_object, context, _params)
      return true if condition.blank?

      result = ::Liquidum.render(condition,
                                 {
                                   assigns: context.reject { |h| h == 'pdf' }.merge('template' => self),
                                   registers: { 'template' => self }
                                 })

      return true if result.strip.blank?

      !ActiveModel::Type::Boolean::FALSE_VALUES.include? result.strip
    end

    def file_name(context)
      if file_name_template.present?
        "#{Liquidum.render(file_name_template, assigns: context)}.#{kind == 'pdf' ? 'pdf' : 'bin'}"
      else
      "#{description.gsub(/[^a-zA-Z0-9]/, '_').downcase}.#{kind == 'pdf' ? 'pdf' : 'bin'}"
      end
    end

    def translation_scope
      scope = %w[]
      scope << description.underscore.gsub(/[^a-z]+/, '_') if description
      scope.join('.')
    end

    def previewable?
      persisted? && example_data.present?
    end

    private

    def paper_kind
      case kind
      when 'pdf'
        'pdf'
      when 'liquid'
        'raw'
      else
        'file'
      end
    end
  end
end
