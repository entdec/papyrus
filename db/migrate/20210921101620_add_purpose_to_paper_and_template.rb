class AddPurposeToPaperAndTemplate < ActiveRecord::Migration[6.1]
  def change
    add_column :papyrus_papers, :purpose, :string
    add_column :papyrus_templates, :purpose, :string
  end
end
