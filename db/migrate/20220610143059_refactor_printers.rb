class RefactorPrinters < ActiveRecord::Migration[6.1]
  def change
    Papyrus::PreferredPrinter.destroy_all
    Papyrus::Printer.destroy_all

    remove_column :papyrus_printers, :default, :boolean
    remove_column :papyrus_printers, :papers, :string
    remove_column :papyrus_printers, :local, :boolean, default: false
    remove_column :papyrus_printers, :network, :boolean, default: false
    remove_column :papyrus_printers, :shared, :boolean, default: false
    remove_column :papyrus_printers, :connected, :boolean, default: false
    remove_column :papyrus_printers, :port, :string
    remove_column :papyrus_printers, :metadata, :jsonb

    add_reference :papyrus_printers, :computer, null: false, type: :uuid, foreign_key: { to_table: :papyrus_computers }
    add_column :papyrus_printers, :client_id, :integer, null: false, index: true
    add_column :papyrus_printers, :state, :string

    add_reference :papyrus_preferred_printers, :computer, null: false, type: :uuid,
                                                          foreign_key: { to_table: :papyrus_computers }

    remove_reference :papyrus_printers, :owner, polymorphic: true,
                                                optional: false, null: true, type: :uuid
  end
end
