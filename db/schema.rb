# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_12_30_160601) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
  end

  create_table "csv_store_todos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "store_id"
    t.string "title"
    t.integer "order"
    t.boolean "done"
    t.text "__git_options"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "store_sync_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "sync_runs_id"
    t.bigint "stores_id"
    t.index ["stores_id"], name: "index_store_sync_runs_on_stores_id"
    t.index ["sync_runs_id"], name: "index_store_sync_runs_on_sync_runs_id"
  end

  create_table "stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "last_synced_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type"
    t.string "filename"
  end

  create_table "sync_conflicts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "object_id"
    t.text "conflict_info"
    t.bigint "sync_runs_id"
    t.index ["sync_runs_id"], name: "index_sync_conflicts_on_sync_runs_id"
  end

  create_table "sync_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "todos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "short_description"
    t.integer "order"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
