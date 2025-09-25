class ChangePatientsHeightAndWeight < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE patients SET height = 170.0 WHERE height IS NULL"
    execute "UPDATE patients SET weight = 70.0  WHERE weight IS NULL"
    
    change_column_null :patients, :height, false
    change_column_null :patients, :weight, false
  end

  def down
    change_column_null :patients, :height, true
    change_column_null :patients, :weight, true
    change_column_default :patients, :height, from: 170.0, to: nil
    change_column_default :patients, :weight, from: 70.0,  to: nil
  end
end
