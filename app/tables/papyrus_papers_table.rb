# frozen_string_literal: true

class PapyrusPapersTable < ActionTable::ActionTable
  model Papyrus::Paper

  column(:template) { |paper| paper.template.description }
  column(:attachment) do |paper|
    link_to(paper.attachment.filename, main_app.rails_blob_path(paper.attachment, disposition: 'attachment'), title: paper.attachment.filename)
  end
  column(:created) { |paper| ln(paper.created_at) }

  initial_order :description, :asc

  row_link { |paper| papyrus.edit_admin_template_path(paper.template) }

  private

  def scope
    @scope = Papyrus::Paper.all
  end

  def filtered_scope
    @filtered_scope = scope

    @filtered_scope
  end
end
