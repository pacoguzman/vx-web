class RemoveArtifacts < ActiveRecord::Migration
  def up
    drop_table :artifacts
  end

  def down
    create_table "artifacts", force: true do |t|
      t.integer  "build_id",     null: false
      t.string   "file",         null: false
      t.string   "content_type", null: false
      t.string   "file_size",    null: false
      t.string   "file_name",    null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "artifacts", ["build_id"], name: "index_artifacts_on_build_id", using: :btree
  end
end
