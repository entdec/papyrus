class AddEnabledToPapyrusTemplate < ActiveRecord::Migration[6.0]
  def change
    add_column :papyrus_templates, :enabled, :boolean
  end
end
