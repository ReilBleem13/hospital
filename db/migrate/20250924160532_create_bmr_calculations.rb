class CreateBmrCalculations < ActiveRecord::Migration[8.0]
  def change
    create_table :bmr_calculations do |t|
      t.references :patient, null: false, foreign_key: true
      t.string :formula, null: false
      t.decimal :value, precision: 10, scale: 2, null: false
      t.datetime :computed_at, null: false

      t.timestamps
    end

    add_index :bmr_calculations, [:patient_id, :computed_at]
  end
end
