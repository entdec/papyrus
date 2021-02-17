module Papyrus
  class PreferredPrinter < ApplicationRecord
    belongs_to :owner, polymorphic: true
    belongs_to :printer, class_name: 'Papyrus::Printer'

    scope :for_use, ->(use) { where(use: use) }
  end
end
