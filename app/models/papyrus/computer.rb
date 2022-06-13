module Papyrus
  class Computer < ApplicationRecord
    has_many :printers, class_name: 'Printer', foreign_key: 'printer_id', dependent: :destroy
    has_many :preferred_printers, class_name: 'PreferredPrinter', foreign_key: 'printer_id', dependent: :destroy
  end
end
