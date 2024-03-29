class CreateTransactio < ActiveRecord::Migration[6.0]

  def change
    create_table "transaction_log_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
        t.uuid "transaction_log_id"
        t.string "transaction_loggable_type"
        t.uuid "transaction_loggable_id"
        t.datetime "created_at", precision: 6, null: false
        t.datetime "updated_at", precision: 6, null: false
        t.string "event"
        t.string "from"
        t.string "to"
        t.jsonb "object"
        t.jsonb "object_changes"
        t.index ["transaction_log_id"], name: "index_transaction_log_entries_on_transaction_log_id"
        t.index ["transaction_loggable_type", "transaction_loggable_id"], name: "transaction_loggable_index"
    end

    create_table "transaction_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
        t.datetime "created_at", precision: 6, null: false
        t.datetime "updated_at", precision: 6, null: false
    end
  end
end
