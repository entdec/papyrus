module Papyrus
  class ConsolidationSpoolJob < ApplicationJob

    # Max request size PrintNode accepts
    MAX_OUTPUT_SIZE = 50.megabytes

    # Content gets encoded to Base64 so we expect a maximum of 33% increase of size
    # -1 mb just to make sure.
    MAX_RAW_OUTPUT_SIZE = (MAX_OUTPUT_SIZE / 1.33) - 1.megabytes

    def perform(consolidation_id)
      return if consolidation_id.nil?

      papers = Papyrus::Paper.where(consolidation_id: consolidation_id).where.not(owner_id: nil)
      total_papers = papers.count
      Papyrus.config.logger.info("#{self.class.name} has started for consolidation_id: #{consolidation_id}, papers: #{total_papers}")
      return if papers.blank?

      papers = papers.order(created_at: :asc).group_by(&:printer_client_id).transform_values { |g| g.group_by(&:kind) }

      papers.each do |printer_client_id, printer_papers|
        next if printer_client_id.nil?

        printer_papers.each do |kind, kind_papers|
          case kind
          when 'pdf'
            print_pdf_papers(consolidation_id, printer_client_id, kind_papers)
          when 'raw'
            print_raw_papers(consolidation_id, printer_client_id, kind_papers)
          end
        end
      end
    end

    def print_raw_papers(consolidation_id, printer_client_id, raw_papers)
      Papyrus::PrintNodeUtils.retry_on_rate_limit do
        combine_raw_papers(raw_papers) do |raw_data|
          puts raw_data.to_s
          job = Papyrus.print_client.create_printjob(
            PrintNode::PrintJob.new(printer_client_id,
                                    "Combined PDF #{consolidation_id}",
                                    'raw_base64',
                                    Base64.encode64(raw_data),
                                    'Papyrus'),
            {
              qty: 1
            })
        end
      end
    end

    def combine_raw_papers(papers)
      return unless block_given?

      buffer = ''
      total_byte_size = 0

      papers.each do |paper|
        attachment = paper.attachment
        byte_size = attachment.byte_size

        if total_byte_size + byte_size > MAX_RAW_OUTPUT_SIZE
          yield buffer

          buffer = ''
          total_byte_size = 0
        end

        attachment.open do |f|
          buffer << f.read
        end
      end

      yield buffer
    end

    def print_pdf_papers(consolidation_id, printer_client_id, pdf_papers)
      Papyrus::PrintNodeUtils.retry_on_rate_limit do
        combine_pdf_papers(pdf_papers) do |pdf|
          temp = Tempfile.new
          temp.binmode
          temp << pdf
          temp.flush

          job = Papyrus.print_client.create_printjob(
            PrintNode::PrintJob.new(printer_client_id,
                                    "Combined PDF #{consolidation_id}",
                         'pdf_base64',
                                    Base64.encode64(pdf),
                                    'Papyrus'),
            {
              qty: 1
            }
          )
        end
      end
    end

    def combine_pdf_papers(papers)
      return unless block_given?

      combined_pdf = CombinePDF.new
      total_byte_size = 0

      papers.each do |paper|
        attachment = paper.attachment
        copies = (paper.template&.copies || 1)

        # open the attachment
        pdf = nil
        attachment.open do |f|
          pdf = CombinePDF.parse(f.read)
        end

        while copies.positive?
          byte_size = attachment.byte_size

          if total_byte_size + byte_size > MAX_RAW_OUTPUT_SIZE
            pdf_out = combined_pdf.to_pdf
            total_byte_size = pdf_out.bytesize

            if total_byte_size + byte_size > MAX_RAW_OUTPUT_SIZE
              yield pdf_out
              combined_pdf = CombinePDF.new
              total_byte_size = 0
            end
          end

          combined_pdf << pdf
          total_byte_size += byte_size
          copies -= 1

          next unless copies.positive?

          # Insert copies to the combined pdf, copies are smaller in size.
          copy_size = estimate_copy_size(pdf)
          copies_that_fit = ((MAX_RAW_OUTPUT_SIZE - total_byte_size) / copy_size).floor
          copies_that_fit = copies if copies_that_fit > copies

          copies_that_fit.times { combined_pdf << pdf }

          total_byte_size += copies_that_fit * copy_size
          copies -= copies_that_fit

          next unless copies.positive?

          # Not all copies fit. Generate a new PDF and continue.
          yield combined_pdf.to_pdf
          combined_pdf = CombinePDF.new
          total_byte_size = 0
        end
      end

      yield combined_pdf.to_pdf
    end

    # Copying PDF pages will not copy the content of the pages, but only
    # references to the content.
    def estimate_copy_size(pdf)
      # 128 bytes should be enough space to contain references.
      pdf.pages.sum { |page| pdf.send(:object_to_pdf, page).bytesize + 128 }
    end

  end
end
