# frozen_string_literal: true

class PapyrusPapersTable < ActionTable::ActionTable
  model Papyrus::Paper

  column(:owner, sort_field: :owner_id) { |row| row.owner ? "#{row.owner&.name} (#{row.owner_type})" : '-' }
  column(:template, sort_field: :template_id) { |paper| paper.template.description }
  column(:attachment) do |paper|
    begin
      link_to(paper.attachment.filename, main_app.rails_blob_path(paper.attachment, disposition: 'attachment'),
              title: paper.attachment.filename)
    rescue StandardError
      $!.message
    end
  end
  column(:created_at) { |paper| ln(paper.created_at) }

  column :actions, sortable: false do |row|
    content_tag(:span) do
      if row.owner
        concat link_to(content_tag(:i, nil, class: 'fal fa-print'), papyrus.print_paper_path(row.id),
                       title: t('papyrus.paper_table.print'), method: :post)
      end
    end
  end

  initial_order :created_at, :desc

  row_link { |paper| papyrus.edit_admin_template_path(paper.template) }

  private

  def scope
    @scope = Papyrus::Paper.all
  end
end
