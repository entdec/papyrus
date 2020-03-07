# frozen_string_literal: true

class PapyrusTemplatesTable < ActionTable::ActionTable
  model Papyrus::Template

  column(:description)
  column(:metadata) { |template| Nuntius.config.metadata_humanize(template.metadata) }
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
