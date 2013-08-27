class CreateJobLogs < ActiveRecord::Migration
  def change
    create_table :job_logs do |t|
      t.integer   :job_id
      t.integer   :tm
      t.integer   :tm_usec
      t.text      :data
    end

    add_index :job_logs, [:job_id]
    add_index :job_logs, [:job_id, :tm, :tm_usec]
  end
end
