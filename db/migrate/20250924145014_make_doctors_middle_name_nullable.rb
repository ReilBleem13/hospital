class MakeDoctorsMiddleNameNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :doctors, :middle_name, true
  end
end
