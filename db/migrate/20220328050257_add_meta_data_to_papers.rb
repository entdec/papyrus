class AddMetaDataToPapers < ActiveRecord::Migration[6.1]
  def change
    add_column :papyrus_papers, :metadata, :jsonb
  end
end
