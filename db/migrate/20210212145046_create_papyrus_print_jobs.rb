class CreatePapyrusPrintJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :papyrus_print_jobs do |t|
      t.references :papyrus_printer, null: false, foreign_key: true
      t.string :url
      t.text :data

      t.timestamps
    end
  end
end
