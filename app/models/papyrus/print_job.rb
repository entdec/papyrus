module Papyrus
  class PrintJob < ApplicationRecord
    KINDS = %w[pdf txt doc xls generic raw].freeze

    belongs_to :printer, class_name: 'Printer', foreign_key: 'papyrus_printer_id'
  end
end
