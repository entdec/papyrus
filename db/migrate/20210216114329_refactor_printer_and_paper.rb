class RefactorPrinterAndPaper < ActiveRecord::Migration[6.0]
  def change
    rename_column :papyrus_printers, :is_local, :local
    rename_column :papyrus_printers, :is_shared, :shared
    rename_column :papyrus_printers, :is_network, :network

    add_column :papyrus_papers, :use, :string
  end
end
