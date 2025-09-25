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

ActiveRecord::Schema[8.0].define(version: 2025_09_24_193358) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bmr_calculations", force: :cascade do |t|
    t.integer "patient_id", null: false
    t.string "formula", null: false
    t.decimal "value", precision: 10, scale: 2, null: false
    t.datetime "computed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "computed_at"], name: "index_bmr_calculations_on_patient_id_and_computed_at"
    t.index ["patient_id"], name: "index_bmr_calculations_on_patient_id"
  end

  create_table "doctor_patients", force: :cascade do |t|
    t.integer "doctor_id", null: false
    t.integer "patient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "patient_id"], name: "index_doctor_patients_on_doctor_id_and_patient_id", unique: true
    t.index ["doctor_id"], name: "index_doctor_patients_on_doctor_id"
    t.index ["patient_id"], name: "index_doctor_patients_on_patient_id"
  end

  create_table "doctors", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "middle_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patients", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "middle_name"
    t.date "birthday", null: false
    t.string "gender", null: false
    t.integer "height", null: false
    t.integer "weight", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["first_name", "last_name", "middle_name", "birthday"], name: "index_patients_fullname_and_birthday", unique: true
  end

  add_foreign_key "bmr_calculations", "patients"
  add_foreign_key "doctor_patients", "doctors"
  add_foreign_key "doctor_patients", "patients"
end
