class ItemDrop < ApplicationDrop
  delegate :state, :name, :description, to: :@object
end
