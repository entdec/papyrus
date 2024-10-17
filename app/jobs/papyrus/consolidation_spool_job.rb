require "combine_pdf"

module Papyrus
  class ConsolidationSpoolJob < ApplicationJob

    # Max request size PrintNode accepts
    MAX_OUTPUT_SIZE = 50.megabytes

    # Content gets encoded to Base64 so we expect a maximum of 33% increase of size
    # -1 mb just to make sure.
    MAX_RAW_OUTPUT_SIZE = (MAX_OUTPUT_SIZE / 1.33) - 1.megabytes

    CONSOLIDATION_TIMEOUT = 10.seconds

    def perform(consolidation_id, options = {})
      return if consolidation_id.nil?
      options = {} unless options.is_a?(Hash)
      options = options.with_indifferent_access

      papers = Papyrus::Paper
                 .joins("LEFT JOIN papyrus_preferred_printers
                   ON papyrus_preferred_printers.owner_id = papyrus_papers.owner_id
                   AND papyrus_preferred_printers.owner_type = papyrus_papers.owner_type AND papyrus_papers.use = papyrus_preferred_printers.use")
                 .joins("LEFT JOIN papyrus_printers ON papyrus_printers.id = papyrus_preferred_printers.printer_id")

      papers = papers.where("papyrus_preferred_printers.computer_id = ?", Papyrus.config.current_computer) if Papyrus.config.current_computer

      papers = papers.where(consolidation_id: consolidation_id)
                     .where.not(owner_id: nil)
                     .select("papyrus_papers.*, papyrus_printers.client_id")
                     .group("papyrus_printers.client_id", :group_id, :id)
                     .order("papyrus_printers.client_id": :asc, group_id: :asc)

      purposes = options[:purposes]
      if purposes.present?
        case_statement = Arel::Nodes::Case.new(Arel.sql("papyrus_papers.purpose"))
        purposes.each_with_index do |purpose, index|
          case_statement.when(Arel::Nodes::Quoted.new(purpose)).then(index + 1)
        end
        case_statement.else(purposes.size + 1)
        papers = papers.order(case_statement.asc.nulls_last)
      end

      # Then apply other sorting (kind, created_at) to refine within the groups
      papers = papers.order(kind: :asc, created_at: :asc)

      return if papers.empty?

      buffer_pdf = new_buffer("pdf")
      buffer_raw = new_buffer("raw")
      timer_pdf = nil
      timer_raw = nil
      current_client_id_pdf = nil
      current_client_id_raw = nil

      in_batches(papers) do |papers_batch|
        papers_batch.each do |paper|
          case paper.kind
          when "pdf"
            if paper.printer_client_id != current_client_id_pdf || timer_pdf.nil?
              flush_print_buffer(consolidation_id, current_client_id_pdf, "pdf", buffer_pdf) if buffer_pdf.present?
              current_client_id_pdf = paper.printer_client_id
              timer_pdf = Time.now
            elsif Time.now - CONSOLIDATION_TIMEOUT < timer_pdf
              flush_print_buffer(consolidation_id, current_client_id_pdf, "pdf", buffer_pdf)
              timer_pdf = Time.now
            end

            append_paper(paper, buffer_pdf)

            if buffer_size_exceeded?("pdf", buffer_pdf)
              flush_print_buffer(consolidation_id, current_client_id_pdf, "pdf", buffer_pdf)
              timer_pdf = Time.now
            end
          else
            if paper.printer_client_id != current_client_id_raw || timer_raw.nil?
              flush_print_buffer(consolidation_id, current_client_id_raw, "raw", buffer_raw) if buffer_raw.present?
              current_client_id_raw = paper.printer_client_id
              timer_raw = Time.now
            elsif Time.now - CONSOLIDATION_TIMEOUT < timer_raw
              flush_print_buffer(consolidation_id, current_client_id_raw, "raw", buffer_raw)
              timer_raw = Time.now
            end

            append_paper(paper, buffer_raw)

            if buffer_size_exceeded?("raw", buffer_raw)
              flush_print_buffer(consolidation_id, current_client_id_raw, "raw", buffer_raw)
              timer_raw = Time.now
            end
          end
        end
      end

      flush_print_buffer(consolidation_id, current_client_id_pdf, "pdf", buffer_pdf) if buffer_pdf.present? && buffer_not_empty?(buffer_pdf, "pdf")
      flush_print_buffer(consolidation_id, current_client_id_raw, "raw", buffer_raw) if buffer_raw.present? && buffer_not_empty?(buffer_raw, "raw")
    end

    def print_raw_papers(consolidation_id, printer_client_id, raw_papers)
      Papyrus::PrintNodeUtils.retry_on_rate_limit do
        combine_raw_papers(raw_papers) do |raw_data|
          Papyrus.print_client.create_printjob(
            PrintNode::PrintJob.new(printer_client_id,
                                    "Consolidation #{consolidation_id}",
                                    "raw_base64",
                                    Base64.encode64(raw_data),
                                    "Papyrus"),
            {
              qty: 1
            })
        end
      end
    end

    def combine_raw_papers(papers)
      return unless block_given?

      buffer = StringIO.new

      papers.each do |paper|
        paper.generate_attachment
        attachment = paper.attachment
        byte_size = attachment.byte_size

        if buffer.size + byte_size > MAX_RAW_OUTPUT_SIZE
          yield buffer.string
          buffer.truncate(0)
          buffer.rewind
        end

        attachment.open do |f|
          buffer.write(f.read)
        end
      end

      yield buffer.string
    end

    def print_pdf_papers(consolidation_id, printer_client_id, pdf_papers)
      Papyrus::PrintNodeUtils.retry_on_rate_limit do
        combine_pdf_papers(pdf_papers) do |pdf|
          Papyrus.print_client.create_printjob(
            PrintNode::PrintJob.new(printer_client_id,
                                    "Consolidation #{consolidation_id}",
                                    "pdf_base64",
                                    Base64.encode64(pdf),
                                    "Papyrus"),
            {
              qty: 1
            }
          )
        end
      end
    end

    def in_batches(papers, batch_size: 500, offset: 0)
      return unless block_given?

      loop do
        papers_batch = papers.offset(offset).limit(batch_size).to_a
        count = papers_batch.count
        break if count.zero?
        yield papers_batch
        offset += count
        break if count < batch_size
      end
      offset
    end

    def combine_pdf_papers(papers)
      return unless block_given?

      combined_pdf = ::CombinePDF.new
      total_byte_size = 0

      papers.each do |paper|
        paper.generate_attachment
        attachment = paper.attachment
        copies = (paper.template&.copies || 1)

        pdf = nil
        attachment.open do |f|
          pdf = ::CombinePDF.parse(f.read)
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

          copy_size = estimate_copy_size(pdf)
          copies_that_fit = ((MAX_RAW_OUTPUT_SIZE - total_byte_size) / copy_size).floor
          copies_that_fit = copies if copies_that_fit > copies

          copies_that_fit.times { combined_pdf << pdf }

          total_byte_size += copies_that_fit * copy_size
          copies -= copies_that_fit

          next unless copies.positive?

          yield combined_pdf.to_pdf
          combined_pdf = ::CombinePDF.new
          total_byte_size = 0
        end
      end

      yield combined_pdf.to_pdf
    end

    # Copying PDF pages will not copy the content of the pages, but only
    # references to the content.
    def estimate_copy_size(pdf)
      pdf.pages.sum { |page| pdf.send(:object_to_pdf, page).bytesize + 128 }
    end

    def flush_print_buffer(consolidation_id, client_id, kind, buffer)
      return unless client_id && kind && buffer.present?
      data = case kind
             when "pdf"
               buffer.to_pdf
             else
               buffer.string
             end

      unless data.blank?
        Papyrus::PrintNodeUtils.retry_on_rate_limit do
          Papyrus.print_client.create_printjob(
            PrintNode::PrintJob.new(
              client_id,
              "Consolidation #{consolidation_id}",
              "#{kind}_base64",
              Base64.encode64(data),
              "Papyrus"
            ),
            {qty: 1}
          )
        end
      end

      if buffer.is_a?(StringIO) && buffer_not_empty?(buffer, kind)
        buffer.truncate(0)
        buffer.rewind
      else
        new_buffer(kind)
      end
    end

    def new_buffer(kind)
      case kind
      when "pdf"
        CombinePDF.new
      else
        StringIO.new
      end
    end

    def append_paper(paper, buffer)
      paper.generate_attachment
      attachment = paper.attachment

      case paper.kind
      when "pdf"
        pdf = nil
        attachment.open do |f|
          pdf = ::CombinePDF.parse(f.read)
        end
        buffer << pdf
      else
        attachment.open do |f|
          buffer.write(f.read)
        end
      end
    end

    def buffer_size_exceeded?(kind, buffer)
      case kind
      when "pdf"
        buffer.to_pdf.bytesize > MAX_RAW_OUTPUT_SIZE
      else
        buffer.size > MAX_RAW_OUTPUT_SIZE
      end
    end

    def buffer_not_empty?(buffer, kind)
      case kind
      when "pdf"
        buffer.pages.any?
      else
        buffer.size > 0
      end
    end

  end
end
