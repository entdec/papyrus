class AddFileNameToTemplate < ActiveRecord::Migration[7.0]
  def change
    add_column :papyrus_templates, :file_name_template, :text
  end
end
