module Papyrus
  class PrintJob < ApplicationRecord
    KINDS = %w[pdf txt doc xls generic raw].freeze

    belongs_to :printer, class_name: 'Papyrus::Printer'
    belongs_to :paper, class_name: 'Papyrus::Paper'
    has_one :template, through: :paper, class_name: 'Papyrus::Template'
  end
end
