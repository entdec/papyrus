class AddKindToTemplate < ActiveRecord::Migration[6.0]
  def change
    add_column :papyrus_templates, :kind, :string
  end
end
