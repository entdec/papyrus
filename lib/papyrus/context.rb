# frozen_string_literal: true

module Papyrus
  # This class provides context for the prawn templates
  class Context
    attr_reader :template

    def initialize(template)
      @template = template
    end

    # Shorter way of defining a method
    def method(name, &block)
      define_singleton_method(name.to_sym, &block)
    end

    # Open one of the named attachments on a template
    def open(filename)
      if filename.is_a? String
        @files ||= {}
        if @files[filename]
          @files[filename].rewind

          return @files[filename]
        end

        attachment = template.attachments.detect { |a| a.blob.filename == filename }
        return unless attachment

        # Not ideal
        @files[filename] = StringIO.new(attachment.blob.download)

      elsif filename.is_a?(ActiveStorage::Attached::One) || (filename.is_a?(Liquid::Drop) && filename.is_for_a?(ActiveStorage::Attached::One) && filename.respond_to?(:download))
        StringIO.new(filename.download)
      end
    end

    def translate(input, options = {})
      result = nil

      Papyrus.i18n_store.with(@template) do |obj|
        locale = options.delete('locale')

        key = input
        scope = nil

        if key.start_with?('.')
          key = input[1..-1]
          scope = obj.translation_scope
        end

        result = I18n.t(key, options.merge(locale: locale, scope: scope, cascade: { skip_root: false }))
        result = I18n::Backend::Simple.new.send(:interpolate, I18n.locale, result, options.symbolize_keys) if result
      end

      result
    end
    alias t translate

    def localize(input, format: nil, locale: 'en')
      I18n.l(input, format: format, locale: locale)
    end
    alias l localize
  end
end
