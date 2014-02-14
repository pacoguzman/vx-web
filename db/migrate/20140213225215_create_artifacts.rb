class CreateArtifacts < ActiveRecord::Migration
  def change
    create_table :artifacts do |t|
      t.integer :build_id,     null: false
      t.string  :file,         null: false
      t.string  :content_type, null: false
      t.string  :file_size,    null: false
      t.string  :file_name,    null: false
      t.timestamps
    end
    add_index :artifacts, :build_id
  end
end
