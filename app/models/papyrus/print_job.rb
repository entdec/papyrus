module Papyrus
  class PrintJob < ApplicationRecord
    KINDS = %w[pdf txt doc xls generic raw].freeze

    belongs_to :printer, class_name: 'Papyrus::Printer'
    belongs_to :paper, class_name: 'Papyrus::Paper'
    has_one :template, through: :paper, class_name: 'Papyrus::Template'

    def send!
      Papyrus::PrintChannel.broadcast_to(printer.owner, {
                                           printer: printer.name,
                                           url: Rails.application.routes.url_helpers.rails_blob_path(paper.attachment, disposition: 'attachment',
                                                                                                                       only_path: true),
                                           kind: paper.kind,
                                           filename: paper.attachment.blob.filename.to_s,
                                           content_type: paper.attachment.blob.content_type,
                                           copies: template.copies
                                         })
    end
  end
end
