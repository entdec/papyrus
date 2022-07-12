# frozen_string_literal: true

class PapyrusPrintJobsTable < ActionTable::ActionTable
  model Papyrus::PrintJob

  column(:state, &:state)
  column(:owner, sortable: false) { |row| row.paper.owner.name }
  column(:computer, sort_field: :printer_id) { |row| row.printer.computer.name }
  column(:printer, sort_field: :printer_id) { |row| row.printer.name }
  column(:paper, sortable: false) { |row| row.paper.template&.description }
  column(:created_at) { |paper| ln(paper.created_at) }

  column :actions, sortable: false do |row|
    content_tag(:span) do
      concat link_to(content_tag(:i, nil, class: 'fal fa-repeat'), papyrus.resend_print_job_path(row.id),
                     title: t('papyrus.print_jobs_table.resend'), data: { method: :post, turbo_method: :post })
    end
  end

  initial_order :created_at, :desc

  # row_link { |paper| papyrus.edit_admin_template_path(paper.template) }

  private

  def scope
    @scope = Papyrus::PrintJob.all
  end
end
