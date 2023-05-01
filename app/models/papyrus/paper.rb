# frozen_string_literal: true

module Papyrus
  class Paper < ApplicationRecord
    belongs_to :template, optional: true
    belongs_to :papyrable, polymorphic: true, optional: true
    belongs_to :owner, polymorphic: true, optional: true

    has_one_attached :attachment

    has_many :print_jobs, class_name: 'PrintJob', dependent: :destroy

    after_create_commit :print!, if: -> { !consolidated? }

    def print!
      return if owner.blank?
      return unless printer
      return if Rails.env.test?

      print_job = printer.print_jobs.create!(paper: self)
      Papyrus::SpoolPrintJob.perform_later(print_job)
      print_job
    end

    def attachment_path
      Rails.application.routes.url_helpers.rails_blob_path(attachment, disposition: 'attachment',
                                                                       only_path: true)
    end

    def consolidated?
      consolidation_id.present?
    end

    def printer_client_id
      printer&.client_id
    end

    private

    def printer
      scope = owner.preferred_printers
      scope = scope.where(computer: Papyrus.config.current_computer) if Papyrus.config.current_computer
      scope.for_use(use).first&.printer
    end
  end
end
