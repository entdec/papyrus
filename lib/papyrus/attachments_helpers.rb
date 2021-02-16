# frozen_string_literal: true

module Papyrus
  module AttachmentsHelpers
    extend ActiveSupport::Concern
    included do
      has_many_attached :attachments unless defined?(Papyrus::Template::AttachmentsAttachmentsAssociationExtension)
    end
  end
end
