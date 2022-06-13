module Papyrus
  class Printer < ApplicationRecord
    USES = [%w[Document document], %w[Label label]].freeze

    belongs_to :computer, class_name: 'Papyrus::Computer'

    has_many :print_jobs, class_name: 'PrintJob', foreign_key: 'printer_id', dependent: :destroy
  end
end
