class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items, id: :uuid do |t|
      t.string :state
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
