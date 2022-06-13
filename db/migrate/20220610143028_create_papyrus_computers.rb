class CreatePapyrusComputers < ActiveRecord::Migration[6.1]
  def change
    create_table :papyrus_computers, id: :uuid do |t|
      t.integer :client_id, index: true
      t.string :name
      t.string :hostname
      t.string :state

      t.timestamps
    end
  end
end
