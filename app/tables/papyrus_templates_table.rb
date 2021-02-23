# frozen_string_literal: true

class PapyrusTemplatesTable < ActionTable::ActionTable
  model Papyrus::Template

  column(:description)
  column(:enabled, as: :boolean)
  column(:klass)
  column(:event)
  column(:kind)
  column(:use)
  column(:copies)
  column(:metadata) { |template| Papyrus.config.metadata_humanize(template.metadata) }
  column(:created_at) { |paper| ln(paper.created_at) }

  initial_order :description, :asc

  row_link { |template| papyrus.edit_admin_template_path(template) }

  private

  def scope
    @scope = Papyrus::Template.visible
  end

  def filtered_scope
    @filtered_scope = scope

    @filtered_scope
  end
end
