module Papyrus
  class Printer < ApplicationRecord
    belongs_to :owner, polymorphic: true
    has_many :print_jobs, class_name: 'PrintJob', foreign_key: 'papyrus_printer_id', dependent: :destroy
  end
end
