# frozen_string_literal: true

module Papyrus
  class Paper < ApplicationRecord
    belongs_to :template
    belongs_to :papyrable, polymorphic: true, optional: true
    belongs_to :owner, polymorphic: true, optional: true

    has_one_attached :attachment

    def print!
      return if owner.blank?
      return unless printer

      print_job = printer.print_jobs.create!(paper: self)
      print_job.send!
      print_job
    end

    def kind
      case template.kind
      when 'pdf'
        'pdf'
      when 'liquid'
        'raw'
      else
        'file'
      end
    end

    private

    def printer
      owner.preferred_printers.for_use(template.use).first&.printer
    end
  end
end
