# frozen_string_literal: true

class PapyrusTemplatesTable < ActionTable::ActionTable
  model Papyrus::Template

  column(:description)
  column(:enabled, as: :boolean)
  column(:klass)
  column(:event)
  column(:papers_count, sort_field: 'papers_count') { |template| link_to template.papers_count, papyrus.root_path(template_id: template.id) }
  column(:kind)
  column(:use)
  column(:copies)
  column(:metadata) { |template| Papyrus.config.metadata_humanize(template.metadata) }
  column(:created_at, html_value: proc { |paper| ln(paper.created_at) })

  initial_order :description, :asc

  row_link { |template| papyrus.edit_admin_template_path(template) }

  private

  def scope
    @scope = Papyrus::Template.visible
    @scope = @scope.select('papyrus_templates.*, (select count(id) from papyrus_papers where papyrus_papers.template_id = papyrus_templates.id) as papers_count')
  end
end
