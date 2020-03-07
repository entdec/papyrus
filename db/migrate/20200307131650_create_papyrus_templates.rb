# frozen_string_literal: true

class CreatePapyrusTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :papyrus_templates, id: :uuid do |t|
      t.string :description
      t.text :data
      t.jsonb :metadata

      t.timestamps
    end
  end
end
