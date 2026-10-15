# frozen_string_literal: true

module Papyrus
  class TemplatesTable < Papyrus::ApplicationTable
    definition do
      model Papyrus::Template
      supports_custom_views true
      show_header true
      exportable true
      internal :id

      column :description
      column :enabled
      column :klass
      column :event
      column(:papers_count) do
        attribute '(SELECT COUNT(*) FROM papyrus_papers WHERE papyrus_papers.template_id = papyrus_templates.id)'
        type :integer
        render do
          html { |template| link_to template.papers_count, papyrus.root_path(template_id: template.id) }
        end
      end
      column :kind
      column :use
      column :copies
      column(:metadata) do
        render do
          html { |template| Papyrus.config.metadata_humanize(template.metadata) }
          csv { |template| Papyrus.config.metadata_humanize(template.metadata) }
        end
      end
      column :created_at
      order description: :asc, id: :asc
      link { |template| papyrus.edit_admin_template_path(template) }
    end

    def scope
      Papyrus::Template.visible
    end
  end
end
