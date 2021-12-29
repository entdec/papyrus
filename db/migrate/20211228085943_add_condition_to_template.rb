class AddConditionToTemplate < ActiveRecord::Migration[6.1]
  def change
    add_column :papyrus_templates, :condition, :text
  end
end
