# frozen_string_literal: true

module Papyrus::AttachmentsHelpers
  extend ActiveSupport::Concern
  included do
    has_many_attached :attachments
  end
end
