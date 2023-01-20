# frozen_string_literal: true

class PapyrusPapersTable < ActionTable::ActionTable
  model Papyrus::Paper

  column(:owner, sort_field: :owner_id) { |row| row.owner ? "#{row.owner&.name} (#{row.owner_type})" : '-' }
  column(:template, sort_field: :template_id) do |paper|
    paper.template ? link_to(paper.template.description, papyrus.edit_admin_template_path(paper.template)) : ''
  end
  column(:attachment, sort_field: 'active_storage_blobs.filename ') do |paper|
    link_to(paper.attachment.filename, main_app.rails_blob_path(paper.attachment, disposition: 'attachment'),
            title: paper.attachment.filename)
  rescue StandardError
    $!.message
  end
  column(:created_at) { |paper| ln(paper.created_at) }

  column :actions, sortable: false do |row|
    content_tag(:span) do
      concat link_to(content_tag(:i, nil, class: 'fal fa-eye'), papyrus.paper_path(row),
                     title: t('papyrus.paper_table.preview'), target: '_blank')
      if row.owner
        concat link_to(content_tag(:i, nil, class: 'fal fa-print'), papyrus.print_paper_path(row.id),
                       title: t('papyrus.paper_table.print'), data: { turbo_method: :post })
      end

      if row.template&.event.present?
        concat link_to(content_tag(:i, nil, class: 'fal fa-rotate-right'), papyrus.regenerate_paper_path(row),
                       title: t('papyrus.paper_table.regenerate'), data: { turbo_method: :post })
      end
    end
  end

  initial_order :created_at, :desc

  private

  def scope
    @scope = Papyrus::Paper.all

    if params[:papyrable_id] && params[:papyrable_type]
      @scope = @scope.where(papyrable_type: params[:papyrable_type],
                            papyrable_id: params[:papyrable_id])
    elsif params[:papyrable]
      @scope = @scope.where(papyrable: params[:papyrable])
    end
    @scope = @scope.joins(attachment_attachment: :blob) if params[:order_field_name] = 'attachment'
    @scope
  end
end
