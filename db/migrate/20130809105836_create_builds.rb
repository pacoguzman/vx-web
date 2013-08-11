class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.integer   :number,      null: false
      t.integer   :project_id,  null: false

      t.string    :sha,         null: false
      t.string    :branch,      null: false

      t.integer   :pull_request_id
      t.string    :author
      t.string    :message

      t.integer   :status,      null: false, default: 0
      t.timestamp :started_at
      t.timestamp :finished_at

      t.timestamps
    end

    add_index :builds, [:project_id, :number], unique: true
  end
end
