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

ActiveRecord::Schema[8.0].define(version: 2025_07_28_171849) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "apps", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_apps_on_name", unique: true
  end

  create_table "availabilities", force: :cascade do |t|
    t.bigint "app_id", null: false
    t.bigint "content_id", null: false
    t.string "market", null: false
    t.jsonb "stream_info", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id", "content_id", "market"], name: "index_availabilities_on_app_id_and_content_id_and_market", unique: true
    t.index ["app_id"], name: "index_availabilities_on_app_id"
    t.index ["content_id"], name: "index_availabilities_on_content_id"
    t.index ["market"], name: "index_availabilities_on_market"
  end

  create_table "contents", force: :cascade do |t|
    t.string "type", null: false
    t.string "original_title", null: false
    t.integer "year"
    t.integer "duration_in_seconds"
    t.integer "season_number"
    t.integer "episode_number"
    t.bigint "tv_show_id"
    t.bigint "season_id"
    t.bigint "channel_id"
    t.jsonb "stream_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_contents_on_channel_id"
    t.index ["season_id"], name: "index_contents_on_season_id"
    t.index ["tv_show_id"], name: "index_contents_on_tv_show_id"
    t.index ["type", "season_id"], name: "index_contents_on_type_and_season_id"
    t.index ["type", "tv_show_id"], name: "index_contents_on_type_and_tv_show_id"
    t.index ["type"], name: "index_contents_on_type"
  end

  create_table "user_apps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "app_id", null: false
    t.integer "position"
    t.index ["app_id"], name: "index_user_apps_on_app_id"
    t.index ["user_id", "app_id"], name: "index_user_apps_on_user_id_and_app_id", unique: true
    t.index ["user_id"], name: "index_user_apps_on_user_id"
  end

  create_table "user_contents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "content_id", null: false
    t.integer "watched_time"
    t.index ["content_id"], name: "index_user_contents_on_content_id"
    t.index ["user_id", "content_id"], name: "index_user_contents_on_user_id_and_content_id", unique: true
    t.index ["user_id"], name: "index_user_contents_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "username", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["token"], name: "index_users_on_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "availabilities", "apps"
  add_foreign_key "availabilities", "contents"
  add_foreign_key "contents", "contents", column: "channel_id"
  add_foreign_key "contents", "contents", column: "season_id"
  add_foreign_key "contents", "contents", column: "tv_show_id"
  add_foreign_key "user_apps", "apps"
  add_foreign_key "user_apps", "users"
  add_foreign_key "user_contents", "contents"
  add_foreign_key "user_contents", "users"
end
