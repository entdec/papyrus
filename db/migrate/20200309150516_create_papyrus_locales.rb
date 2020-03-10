# frozen_string_literal: true

class CreatePapyrusLocales < ActiveRecord::Migration[6.0]
  def change
    create_table :papyrus_locales, id: :uuid do |t|
      t.string :key
      t.jsonb :data
      t.jsonb :metadata

      t.timestamps
    end
  end
end
