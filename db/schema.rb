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

ActiveRecord::Schema.define(version: 2020_07_28_174400) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "lease_types", force: :cascade do |t|
    t.string "lease_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "duration_months"
  end

  create_table "leases", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lease_type_id", null: false
    t.boolean "status"
    t.decimal "monthly_rent_price"
    t.decimal "balance"
    t.bigint "property_address_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.decimal "first_month_rent"
    t.decimal "last_month_rent"
    t.decimal "security_deposit"
    t.index ["lease_type_id"], name: "index_leases_on_lease_type_id"
    t.index ["property_address_id"], name: "index_leases_on_property_address_id"
    t.index ["user_id"], name: "index_leases_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "lease_id", null: false
    t.decimal "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lease_id"], name: "index_payments_on_lease_id"
  end

  create_table "property_addresses", force: :cascade do |t|
    t.string "street_address"
    t.string "apartment"
    t.string "zip"
    t.string "city"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_contacts", force: :cascade do |t|
    t.string "street_address"
    t.string "apartment"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "email"
    t.bigint "user_id", null: false
    t.string "address_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_contacts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "firstname"
    t.string "lastname"
    t.string "password_digest"
    t.boolean "admin"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "comments", "users"
  add_foreign_key "leases", "lease_types"
  add_foreign_key "leases", "property_addresses"
  add_foreign_key "leases", "users"
  add_foreign_key "payments", "leases"
  add_foreign_key "user_contacts", "users"
end
