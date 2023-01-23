class AddDescriptionToPapyrusPrinters < ActiveRecord::Migration[7.0]
  def change
    add_column :papyrus_printers, :description, :string
  end
end
