# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150430213351) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cars", force: :cascade do |t|
    t.string   "name",                        null: false
    t.integer  "mileage",         default: 0, null: false
    t.integer  "rides_count",     default: 0, null: false
    t.integer  "owners_count",    default: 0, null: false
    t.integer  "borrowers_count", default: 0, null: false
    t.integer  "comments_count",  default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cars", ["name"], name: "index_cars_on_name", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "commentable_id", null: false
    t.string   "type",           null: false
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["type"], name: "index_comments_on_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "car_id",     null: false
    t.decimal  "latitude",   null: false
    t.decimal  "longitude",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["car_id"], name: "index_locations_on_car_id", using: :btree
  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "car_id",     null: false
    t.string   "type",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["type"], name: "index_relationships_on_type", using: :btree
  add_index "relationships", ["user_id", "car_id"], name: "index_relationships_on_user_id_and_car_id", unique: true, using: :btree

  create_table "reservations", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.integer  "car_id",                     null: false
    t.datetime "starts_at",                  null: false
    t.datetime "ends_at",                    null: false
    t.integer  "comments_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reservations", ["car_id"], name: "index_reservations_on_car_id", using: :btree
  add_index "reservations", ["ends_at"], name: "index_reservations_on_ends_at", using: :btree
  add_index "reservations", ["starts_at"], name: "index_reservations_on_starts_at", using: :btree
  add_index "reservations", ["user_id"], name: "index_reservations_on_user_id", using: :btree

  create_table "rides", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "car_id",                     null: false
    t.integer  "distance",                   null: false
    t.datetime "started_at",                 null: false
    t.datetime "ended_at",                   null: false
    t.integer  "comments_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rides", ["car_id"], name: "index_rides_on_car_id", using: :btree
  add_index "rides", ["distance"], name: "index_rides_on_distance", using: :btree
  add_index "rides", ["ended_at"], name: "index_rides_on_ended_at", using: :btree
  add_index "rides", ["started_at"], name: "index_rides_on_started_at", using: :btree
  add_index "rides", ["user_id"], name: "index_rides_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",        null: false
    t.string   "email",           null: false
    t.string   "password_digest", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
