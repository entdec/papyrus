# frozen_string_literal: true

module Papyrus
  class PapersTable < Papyrus::ApplicationTable
    definition do
      model Papyrus::Paper
      supports_custom_views false
      show_header true
      exportable true

      internal :id
      internal :owner_id
      internal :owner_type
      internal :template_id
      internal(:template_description) { attribute 'papyrus_templates.description' }
      internal(:template_event) { attribute 'papyrus_templates.event' }

      column(:owner) do
        attribute 'papyrus_papers.owner_id'
        type :uuid
        render do
          html { |paper| paper.owner ? "#{paper.owner.name} (#{paper.owner_type})" : '-' }
          csv { |paper| paper.owner ? "#{paper.owner.name} (#{paper.owner_type})" : '-' }
        end
      end
      column(:template) do
        attribute 'papyrus_papers.template_id'
        type :uuid
        render do
          html { |paper| paper[:template_description] ? link_to(paper[:template_description], papyrus.edit_admin_template_path(paper.template_id)) : '' }
          csv { |paper| paper[:template_description] }
        end
      end
      column(:attachment) do
        attribute 'active_storage_blobs.filename'
        render do
          html do |paper|
            if paper.attachment.attached?
              begin
                link_to(paper[:attachment], main_app.rails_blob_path(paper.attachment, disposition: 'attachment'), title: paper[:attachment])
              rescue StandardError => e
                e.message
              end
            else
              '...'
            end
          end
        end
      end
      column :created_at
      column(:consolidation_id) do
        render do
          html { |paper| paper.consolidation_id.presence || '-' }
        end
      end

      action :preview do
        title -> { I18n.t('papyrus.paper_table.preview') }
        icon 'fal fa-eye'
        link { |paper| papyrus.paper_path(paper) }
        link_attributes target: '_blank'
        show ->(paper) { paper.attachment.attached? }
      end
      action :print do
        title -> { I18n.t('papyrus.paper_table.print') }
        icon 'fal fa-print'
        link { |paper| papyrus.print_paper_path(paper) }
        link_attributes data: { turbo_method: :post }
        show ->(paper) { paper.owner.present? && paper.attachment.attached? }
      end
      action :regenerate do
        title -> { I18n.t('papyrus.paper_table.regenerate') }
        icon 'fal fa-rotate-right'
        link { |paper| papyrus.regenerate_paper_path(paper) }
        link_attributes data: { turbo_method: :post }
        show ->(paper) { paper[:template_event].present? }
      end
      action :print_consolidation do
        title -> { I18n.t('papyrus.paper_table.print_consolidation') }
        icon 'fal fa-rectangle-vertical-history'
        link { |paper| papyrus.print_consolidation_paper_path(paper) }
        link_attributes data: { turbo_method: :post }
        show ->(paper) { paper.consolidated? }
      end
      order created_at: :desc, id: :desc
    end

    def scope
      records = Papyrus::Paper.left_outer_joins(:template, attachment_attachment: :blob)
        .preload(:owner, attachment_attachment: :blob)

      if params[:papyrable_id].present? && params[:papyrable_type].present?
        records = records.where(papyrable_type: params[:papyrable_type], papyrable_id: params[:papyrable_id])
      elsif params[:papyrable].present?
        records = records.where(papyrable: params[:papyrable])
      end

      records = records.where(template_id: params[:template_id]) if params[:template_id].present?
      records
    end
  end
end
