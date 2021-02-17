class CreatePapyrusPrinting < ActiveRecord::Migration[6.0]
  def change
    create_table :papyrus_printers, id: :uuid do |t|
      t.references :owner, polymorphic: true, optional: false, null: false, type: :uuid

      t.string :name
      t.boolean :default
      t.string :papers
      t.boolean :local
      t.boolean :network
      t.boolean :shared
      t.boolean :connected
      t.string :port
      t.jsonb :metadata

      t.timestamps
    end

    create_table :papyrus_print_jobs, id: :uuid do |t|
      t.string :status
      t.references :paper, type: :uuid, null: false, foreign_key: { to_table: :papyrus_papers }
      t.references :printer, null: false, foreign_key: { to_table: :papyrus_printers }, type: :uuid
      t.timestamps
    end

    create_table :papyrus_preferred_printers, id: :uuid do |t|
      t.string :use, null: false

      t.references :owner, polymorphic: true, optional: false, null: false, type: :uuid
      t.references :printer, null: false, type: :uuid, foreign_key: { to_table: :papyrus_printers }

      t.timestamps
    end

    add_reference :papyrus_papers, :owner, polymorphic: true, optional: false, null: true, type: :uuid
    add_reference :papyrus_papers, :papyrable, null: true, polymorphic: true, index: false, type: :uuid,
                                               foreign_key: false

    add_column :papyrus_templates, :kind, :string, default: 'pdf'
    add_column :papyrus_templates, :copies, :integer, default: 1
    add_column :papyrus_templates, :klass, :string
    add_column :papyrus_templates, :event, :string
  end
end
