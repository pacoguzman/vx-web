class MakeFileNameUniqueOnCachedFiles < ActiveRecord::Migration
  def change
    add_index :cached_files, [:project_id, :file_name], unique: true
  end
end
