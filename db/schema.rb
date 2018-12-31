# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181231080640) do

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.integer "person_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "face_id"
    t.index ["person_group_id"], name: "index_people_on_person_group_id"
  end

  create_table "person_groups", force: :cascade do |t|
    t.string "name"
    t.string "azure_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_person_groups_on_user_id"
  end

  create_table "shared_dbs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.integer "user_image_id"
    t.integer "person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_tags_on_person_id"
    t.index ["user_image_id"], name: "index_tags_on_user_image_id"
  end

  create_table "user_images", force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
