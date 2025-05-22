class UpdatePapyrusEventIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :papyrus_events, name: :index_papyrus_events_on_transitionable

    add_index :papyrus_events,
              [:transitionable_type, :transitionable_id, :transition_event],
              name: :index_papyrus_events_on_type_id_event
  end
end
