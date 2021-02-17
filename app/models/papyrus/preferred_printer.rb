module Papyrus
  class PreferredPrinter < ApplicationRecord
    belongs_to :owner, polymorphic: true
    belongs_to :printer, class_name: 'Papyrus::Printer'
  end
end
