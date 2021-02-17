class CreatePapyrusPreferredPrinters < ActiveRecord::Migration[6.0]
  def change
    create_table :papyrus_preferred_printers, id: :uuid do |t|
      t.string :use, null: false

      t.references :owner, polymorphic: true, optional: false, null: false, type: :uuid
      t.references :printer, null: false, type: :uuid, foreign_key: { to_table: :papyrus_printers }

      t.timestamps
    end
  end
end
