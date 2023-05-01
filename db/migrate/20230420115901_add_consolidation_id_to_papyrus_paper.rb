class AddConsolidationIdToPapyrusPaper < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :papyrus_papers, :consolidation_id, :string
    add_index :papyrus_papers, :consolidation_id, unique: false, algorithm: :concurrently
  end
end
