module Papyrus
  class PrintJob < ApplicationRecord
    KINDS = %w[pdf txt doc xls generic raw].freeze

    state_machine initial: :pending do
      state :printing
      state :printed
      state :error

      event :started do
        transition any => :printing
      end

      event :errored do
        transition %i[pending printing] => :error
      end

      event :finished do
        transition %i[pending error printing] => :printed
      end
    end

    belongs_to :printer, class_name: 'Papyrus::Printer'
    belongs_to :paper, class_name: 'Papyrus::Paper'
    has_one :template, through: :paper, class_name: 'Papyrus::Template'

    def spool!
      Papyrus::PrintChannel.broadcast_to(printer.owner, payload)
    end

    private

    def payload
      {
        printer: printer.name,
        url: paper.attachment_path,
        kind: paper.kind,
        filename: paper.attachment.blob.filename.to_s,
        content_type: paper.attachment.blob.content_type,
        copies: template.copies
      }
    end
  end
end
