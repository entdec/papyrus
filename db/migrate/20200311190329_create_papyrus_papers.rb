# frozen_string_literal: true

class CreatePapyrusPapers < ActiveRecord::Migration[6.0]
  def change
    create_table :papyrus_papers, id: :uuid do |t|
      t.jsonb :data
      t.references :template, null: false, foreign_key: true, type: :uuid, foreign_key: { to_table: :papyrus_templates }

      t.timestamps
    end
  end
end
