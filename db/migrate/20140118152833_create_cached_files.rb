class CreateCachedFiles < ActiveRecord::Migration
  def change
    create_table :cached_files do |t|
      t.integer :project_id,   null: false
      t.string  :file,         null: false
      t.string  :content_type, null: false
      t.integer :file_size,    null: false
      t.string  :file_name,    null: false
      t.timestamps
    end
  end
end
