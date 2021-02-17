# frozen_string_literal: true

module Papyrus
  class Paper < ApplicationRecord
    belongs_to :template
    belongs_to :papyrable, polymorphic: true, optional: true
    belongs_to :owner, polymorphic: true, optional: true

    has_one_attached :attachment

    def print!
      return if owner.blank?
      return unless printer

      print_job = printer.print_jobs.create!(paper: self)
      Papyrus::PrintChannel.broadcast_to(owner, {
                                           printer: printer.name,
                                           url: Rails.application.routes.url_helpers.rails_blob_path(attachment, disposition: 'attachment',
                                                                                                                 only_path: true),
                                           kind: kind,
                                           filename: attachment.blob.filename.to_s,
                                           content_type: attachment.blob.content_type,
                                           copies: template.copies
                                         })

      print_job
    end

    private

    def printer
      owner.preferred_printers.for_use(template.use).first&.printer
    end

    def kind
      if template.kind == 'pdf'
        'pdf'
      elsif template.kind == 'liquid'
        'raw'
      else
        'file'
      end
    end
  end
end
