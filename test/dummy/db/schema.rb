# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_04_20_115901) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "state"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "papyrus_computers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "client_id"
    t.string "name"
    t.string "hostname"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_papyrus_computers_on_client_id"
  end

  create_table "papyrus_locales", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key"
    t.jsonb "data"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "papyrus_papers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_type"
    t.uuid "owner_id"
    t.string "papyrable_type"
    t.uuid "papyrable_id"
    t.string "kind"
    t.string "use"
    t.string "purpose"
    t.jsonb "metadata"
    t.string "consolidation_id"
    t.index ["consolidation_id"], name: "index_papyrus_papers_on_consolidation_id"
    t.index ["owner_type", "owner_id"], name: "index_papyrus_papers_on_owner_type_and_owner_id"
    t.index ["template_id"], name: "index_papyrus_papers_on_template_id"
  end

  create_table "papyrus_preferred_printers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "use", null: false
    t.string "owner_type", null: false
    t.uuid "owner_id", null: false
    t.uuid "printer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "computer_id", null: false
    t.index ["computer_id"], name: "index_papyrus_preferred_printers_on_computer_id"
    t.index ["owner_type", "owner_id"], name: "index_papyrus_preferred_printers_on_owner_type_and_owner_id"
    t.index ["printer_id"], name: "index_papyrus_preferred_printers_on_printer_id"
  end

  create_table "papyrus_print_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "state", default: "pending"
    t.uuid "paper_id", null: false
    t.uuid "printer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paper_id"], name: "index_papyrus_print_jobs_on_paper_id"
    t.index ["printer_id"], name: "index_papyrus_print_jobs_on_printer_id"
  end

  create_table "papyrus_printers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "computer_id", null: false
    t.integer "client_id", null: false
    t.string "state"
    t.string "description"
    t.index ["computer_id"], name: "index_papyrus_printers_on_computer_id"
  end

  create_table "papyrus_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description"
    t.text "data"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "example_data", default: {}
    t.string "kind", default: "pdf"
    t.integer "copies", default: 1
    t.string "klass"
    t.string "event"
    t.string "use"
    t.boolean "enabled"
    t.string "purpose"
    t.text "condition"
    t.text "file_name_template"
  end

  create_table "transaction_log_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "transaction_log_id"
    t.string "transaction_loggable_type"
    t.uuid "transaction_loggable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "event"
    t.string "from"
    t.string "to"
    t.jsonb "object"
    t.jsonb "object_changes"
    t.index ["transaction_log_id"], name: "index_transaction_log_entries_on_transaction_log_id"
    t.index ["transaction_loggable_type", "transaction_loggable_id"], name: "transaction_loggable_index"
  end

  create_table "transaction_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "papyrus_papers", "papyrus_templates", column: "template_id"
  add_foreign_key "papyrus_preferred_printers", "papyrus_computers", column: "computer_id"
  add_foreign_key "papyrus_preferred_printers", "papyrus_printers", column: "printer_id"
  add_foreign_key "papyrus_print_jobs", "papyrus_papers", column: "paper_id"
  add_foreign_key "papyrus_print_jobs", "papyrus_printers", column: "printer_id"
  add_foreign_key "papyrus_printers", "papyrus_computers", column: "computer_id"
end
