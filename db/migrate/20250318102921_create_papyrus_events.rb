class CreatePapyrusEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :papyrus_events do |t|
      t.references :transitionable, type: :uuid, polymorphic: true
      t.string :transition_attribute
      t.string :transition_event
      t.string :transition_from
      t.string :transition_to
      t.jsonb :datastore
      t.timestamps
    end
  end
end
