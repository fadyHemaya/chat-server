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

ActiveRecord::Schema[7.0].define(version: 2022_04_04_140537) do
  create_table "apps", charset: "latin1", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.integer "chats_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_apps_on_token", unique: true
  end

  create_table "chats", charset: "latin1", force: :cascade do |t|
    t.string "app_token", null: false
    t.integer "number"
    t.integer "messages_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_token", "number"], name: "index_chats_on_app_token_and_number", unique: true
  end

  create_table "messages", charset: "latin1", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.integer "number"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id", "number"], name: "index_messages_on_chat_id_and_number", unique: true
  end

  add_foreign_key "chats", "apps", column: "app_token", primary_key: "token"
  add_foreign_key "messages", "chats"
end
