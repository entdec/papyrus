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
      return unless Papyrus.print_client

      started!

      job = Papyrus.print_client.create_printjob(
        PrintNode::PrintJob.new(printer.client_id,
                                template&.description || "Unknown",
                                printer_client_content_type,
                                Base64.encode64(paper.attachment.download),
                                'Papyrus'),
        {
          qty: template&.copies || 1
        }
      )
      info = Papyrus.print_client.printjobs(job)

      finished! if info.first.state == 'queued'
    end

    private

    def printer_client_content_type
      case paper.kind
      when 'liquid'
        'raw_base64'
      when 'pdf'
        'pdf_base64'
      end
    end
  end
end
