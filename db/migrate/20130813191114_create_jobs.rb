class CreateJobs < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS hstore"

    create_table :jobs do |t|
      t.integer   :build_id,   null: false
      t.integer   :number,     null: false
      t.integer   :status,     null: false
      t.hstore    :matrix
      t.datetime  :started_at
      t.datetime  :finished_at

      t.timestamps
    end
    add_index :jobs, [:build_id, :number], unique: true
  end

  def down
    drop_table :jobs
  end
end
