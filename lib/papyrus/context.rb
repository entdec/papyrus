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
      attachment = template.attachments.detect do |a|
        a.blob.filename == filename
      end

      return unless attachment

      # Not ideal
      StringIO.new(attachment.blob.download)
    end
  end
end
