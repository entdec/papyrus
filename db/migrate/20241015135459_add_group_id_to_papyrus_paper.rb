class AddGroupIdToPapyrusPaper < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_column :papyrus_papers, :group_id, :string, default: nil
    add_index :papyrus_papers, :group_id, using: :btree
  end

  def down
    remove_column :papyrus_papers, :group_id
    remove_index :papyrus_papers, :group_id
  end

end
