class AddKindToPaper < ActiveRecord::Migration[6.0]
  def change
    add_column :papyrus_papers, :kind, :string

    remove_column :papyrus_papers, :data, :jsonb
  end
end
