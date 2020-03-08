# frozen_string_literal: true

module Papyrus
  class Context
    attr_reader :template
    def initialize(template)
      @template = template
    end

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
