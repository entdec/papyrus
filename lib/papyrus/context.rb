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
      @files ||= {}
      if @files[filename]
        @files[filename].rewind

        return @files[filename]
      end

      attachment = template.attachments.detect { |a| a.blob.filename == filename }
      return unless attachment

      # Not ideal
      @files[filename] = StringIO.new(attachment.blob.download)
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

        result = I18n.t(key, options, locale: locale, scope: scope, cascade: { skip_root: false })
        if result
          result = I18n::Backend::Simple.new.send(:interpolate, I18n.locale, result, options.symbolize_keys)
        end
      end

      result
    end
    alias t translate

    def localize(input, locale = 'en', format = nil)
      I18n.l(input, format: format, locale: locale)
    end
    alias l localize
  end
end
