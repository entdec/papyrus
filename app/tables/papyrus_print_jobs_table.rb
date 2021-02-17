# frozen_string_literal: true

class PapyrusPrintJobsTable < ActionTable::ActionTable
  model Papyrus::PrintJob

  column(:printer, sort_field: :printer_id) { |row| row.printer.name }
  column(:paper, sortable: false) { |row| row.paper.template.name }
  column(:created_at) { |paper| ln(paper.created_at) }

  initial_order :created_at, :desc

  # row_link { |paper| papyrus.edit_admin_template_path(paper.template) }

  private

  def scope
    @scope = Papyrus::PrintJob.all
  end

  def filtered_scope
    @filtered_scope = scope

    @filtered_scope
  end
end
