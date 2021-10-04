# frozen_string_literal: true

module Papyrus
  class Paper < ApplicationRecord
    belongs_to :template, optional: true
    belongs_to :papyrable, polymorphic: true, optional: true
    belongs_to :owner, polymorphic: true, optional: true

    has_one_attached :attachment

    after_commit :print!

    def print!
      return if owner.blank?
      return unless printer
      return if Rails.env.test?

      print_job = printer.print_jobs.create!(paper: self)
      print_job.spool!
      print_job
    end

    def attachment_path
      Rails.application.routes.url_helpers.rails_blob_path(attachment, disposition: 'attachment',
                                                                       only_path: true)
    end

    private

    def printer
      owner.preferred_printers.for_use(use).first&.printer
    end
  end
end
