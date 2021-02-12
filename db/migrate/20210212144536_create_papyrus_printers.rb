class CreatePapyrusPrinters < ActiveRecord::Migration[6.0]
  def change
    create_table :papyrus_printers do |t|
      t.references :owner, polymorphic: true, optional: false, null: false, type: :uuid

      t.string :name
      t.boolean :default
      t.string :papers
      t.boolean :is_local
      t.boolean :is_network
      t.boolean :is_shared
      t.boolean :connected
      t.string :port
      t.jsonb :metadata

      t.timestamps
    end
  end
end
