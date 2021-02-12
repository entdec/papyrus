class AddKindToPrintJob < ActiveRecord::Migration[6.0]
  def change
    add_column :papyrus_print_jobs, :kind, :string
  end
end
