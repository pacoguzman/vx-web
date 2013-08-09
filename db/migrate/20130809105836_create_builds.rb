class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.integer :number,      null: false
      t.integer :project_id,  null: false
      t.string  :ref,         null: false
      t.string  :branch,      null: false
      t.integer :pull_request_id
      t.string  :author
      t.string  :message

      t.timestamps
    end

    add_index :builds, [:number, :project_id], unique: true
  end
end
