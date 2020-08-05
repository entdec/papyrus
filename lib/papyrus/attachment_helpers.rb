# frozen_string_literal: true

module Papyrus
  module AttachmentHelpers
    extend ActiveSupport::Concern
    included do
      unless defined?(Papyrus::Template::AttachmentsAttachmentsAssociationExtension)
        has_one_attached :attachment
      end
    end
  end
end
