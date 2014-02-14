class UpdateBuildNumberIndex < ActiveRecord::Migration
  def change
    remove_index :builds, column: [:project_id, :number], unique: true
    add_index :builds, [:project_id, :type, :number], unique: true
  end
end
