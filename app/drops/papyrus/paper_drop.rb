# frozen_string_literal: true

module Papyrus
  class PaperDrop < ApplicationDrop
    delegate :id, :kind, :use, :purpose, :created_at, :updated_at, to: :@object

    def attachment
      ActiveStorageAttachedOneDrop.new(@object.attachment)
    end
  end
end
