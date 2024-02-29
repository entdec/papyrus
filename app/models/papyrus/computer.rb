module Papyrus
  class Computer < ApplicationRecord
    has_many :printers, class_name: 'Printer', foreign_key: 'computer_id', dependent: :destroy
    has_many :preferred_printers, class_name: 'PreferredPrinter', foreign_key: 'computer_id', dependent: :destroy
    has_many :users, class_name: 'User', foreign_key: "current_computer_id", dependent: :nullify
  end
end
