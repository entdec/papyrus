# frozen_string_literal: true

class CreatePapyrusTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :papyrus_templates do |t|
      t.text :description
      t.text :data
      t.jsonb :metadata

      t.timestamps
    end
  end
end
