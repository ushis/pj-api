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

ActiveRecord::Schema.define(version: 20150228173556) do

  create_table "cars", force: :cascade do |t|
    t.string   "name",                        null: false
    t.integer  "mileage",         default: 0, null: false
    t.integer  "rides_count",     default: 0, null: false
    t.integer  "owners_count",    default: 0, null: false
    t.integer  "borrowers_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cars", ["name"], name: "index_cars_on_name"

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "commentable_id", null: false
    t.string   "type",           null: false
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id"
  add_index "comments", ["type"], name: "index_comments_on_type"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "positions", force: :cascade do |t|
    t.integer  "car_id",     null: false
    t.float    "latitude",   null: false
    t.float    "longitude",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "positions", ["car_id"], name: "index_positions_on_car_id"

  create_table "relationships", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "car_id",     null: false
    t.string   "type",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["type"], name: "index_relationships_on_type"
  add_index "relationships", ["user_id", "car_id"], name: "index_relationships_on_user_id_and_car_id", unique: true

  create_table "reservations", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "car_id",     null: false
    t.datetime "starts_at",  null: false
    t.datetime "ends_at",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reservations", ["car_id"], name: "index_reservations_on_car_id"
  add_index "reservations", ["ends_at"], name: "index_reservations_on_ends_at"
  add_index "reservations", ["starts_at"], name: "index_reservations_on_starts_at"
  add_index "reservations", ["user_id"], name: "index_reservations_on_user_id"

  create_table "rides", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "car_id",     null: false
    t.integer  "distance",   null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rides", ["car_id"], name: "index_rides_on_car_id"
  add_index "rides", ["ended_at"], name: "index_rides_on_ended_at"
  add_index "rides", ["started_at"], name: "index_rides_on_started_at"
  add_index "rides", ["user_id"], name: "index_rides_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "username",        null: false
    t.string   "email",           null: false
    t.string   "password_digest", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
