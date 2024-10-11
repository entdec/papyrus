# frozen_string_literal: true

module Papyrus
  class Paper < ApplicationRecord
    belongs_to :template, optional: true
    belongs_to :papyrable, polymorphic: true, optional: true
    belongs_to :owner, polymorphic: true, optional: true

    has_one_attached :attachment

    has_many :print_jobs, class_name: 'PrintJob', dependent: :destroy

    after_create_commit :print!, if: -> { !consolidated? }

    def initialize(*args, **kwargs)
      super(*args, **kwargs)
      self.consolidation_id ||= Papyrus.consolidation_id
    end
    def print!
      return if owner.blank?
      return unless printer
      return if Rails.env.test?

      print_job = printer.print_jobs.create!(paper: self)
      Papyrus::SpoolPrintJob.perform_async(print_job.id)
      print_job
    end

    def attachment_path
      Rails.application.routes.url_helpers.rails_blob_path(attachment, disposition: 'attachment',
                                                           only_path: true)
    end

    def consolidated?
      consolidation_id.present?
    end

    def printer_client_id
      printer&.client_id
    end

    def generate_attachment
      return attachment if attachment.attached? || !metadata['context'] || !template

      context = metadata['context']&.transform_values do |v|
        if (v.is_a?(Hash))
          if v['type'] == 'object'
            v['class'].constantize.find(v['id'])
          elsif v['type'] == 'hash'
            v['entries']
          else
            v
          end
        else
          v
        end
      end.with_indifferent_access.to_h

      variable_name = BaseGenerator.liquid_variable_name_for(papyrable)
      context[variable_name] = context[variable_name].is_a?(Hash) ? context[variable_name].deep_stringify_keys : context[variable_name]&.to_liquid

      template.generate_attachment(self, context, metadata['locale'])
      attachment
    end

    def metadata
      super&.with_indifferent_access || {}
    end

    private

    def printer
      scope = owner.preferred_printers
      scope = scope.where(computer: Papyrus.config.current_computer) if Papyrus.config.current_computer
      scope.for_use(use).first&.printer
    end
  end
end
