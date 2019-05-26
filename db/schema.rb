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

ActiveRecord::Schema.define(version: 2019_05_26_062557) do

  create_table "object_tags", force: :cascade do |t|
    t.string "name"
    t.integer "user_image_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_image_id"], name: "index_object_tags_on_user_image_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.integer "person_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "person_id"
    t.string "last_face_id"
    t.integer "face_width"
    t.integer "face_height"
    t.integer "face_offset_x"
    t.integer "face_offset_y"
    t.string "avatar_url"
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

  create_table "relationships", force: :cascade do |t|
    t.integer "person_id"
    t.integer "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_relationships_on_friend_id"
    t.index ["person_id"], name: "index_relationships_on_person_id"
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
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
