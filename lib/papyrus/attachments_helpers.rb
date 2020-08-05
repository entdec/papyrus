# frozen_string_literal: true

module Papyrus
  module AttachmentsHelpers
    extend ActiveSupport::Concern
    included do
      unless defined?(Papyrus::Template::AttachmentsAttachmentsAssociationExtension)
        has_many_attached :attachments
      end
    end
  end
end
