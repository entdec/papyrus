class CreatePapyrusPrintJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :papyrus_print_jobs do |t|
      t.references :printer, null: false, foreign_key: { to_table: :papyrus_printers }, type: :uuid
      t.string :url
      t.text :data

      t.timestamps
    end
  end
end
