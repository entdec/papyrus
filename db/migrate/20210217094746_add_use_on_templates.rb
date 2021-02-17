class AddUseOnTemplates < ActiveRecord::Migration[6.0]
  def change
    remove_column :papyrus_papers, :use, :string
    add_column :papyrus_templates, :use, :string

  end
end
