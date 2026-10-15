# frozen_string_literal: true

module Papyrus
  class PrintJobsTable < Papyrus::ApplicationTable
    definition do
      model Papyrus::PrintJob
      supports_custom_views false
      show_header true
      exportable true
      internal :id
      internal :paper_id
      internal :printer_id

      internal(:computer_name) { attribute 'papyrus_computers.name' }
      internal(:printer_name) { attribute 'papyrus_printers.name' }

      column :state
      column(:owner) do
        sortable false
        render do
          html { |job| job.paper&.owner&.name }
          csv { |job| job.paper&.owner&.name }
        end
      end
      column(:computer) do
        attribute 'papyrus_print_jobs.printer_id'
        type :uuid
        render do
          html { |job| job[:computer_name] }
          csv { |job| job[:computer_name] }
        end
      end
      column(:printer) do
        attribute 'papyrus_print_jobs.printer_id'
        type :uuid
        render do
          html { |job| job[:printer_name] }
          csv { |job| job[:printer_name] }
        end
      end
      column(:paper) do
        attribute 'papyrus_templates.description'
        sortable false
      end
      column :created_at
      action :resend do
        title -> { I18n.t('papyrus.print_jobs_table.resend') }
        icon 'fal fa-repeat'
        link { |job| papyrus.resend_print_job_path(job) }
        link_attributes data: { method: :post, turbo_method: :post }
      end
      order created_at: :desc, id: :desc
    end

    def scope
      Papyrus::PrintJob.left_outer_joins({printer: :computer}, {paper: :template}).preload(paper: :owner)
    end
  end
end
