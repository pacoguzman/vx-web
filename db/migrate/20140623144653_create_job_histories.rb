class CreateJobHistories < ActiveRecord::Migration
  def up
    create_table :job_histories, id: false do |t|
      t.uuid :company_id
      t.integer :duration
      t.integer :build_number
      t.integer :job_number
      t.datetime :created_at
    end

    add_index :job_histories, [:company_id, :created_at]

    execute %{
      INSERT INTO job_histories (company_id, duration, build_number, job_number, created_at)
      SELECT
        projects.company_id AS company_id,
        EXTRACT(EPOCH FROM(jobs.finished_at - jobs.started_at)) AS duration,
        builds.number AS build_number,
        jobs.number AS job_number,
        jobs.finished_at AS created_at
      FROM jobs
      INNER JOIN builds ON builds.id = jobs.build_id
      INNER JOIN projects ON projects.id = builds.project_id
    }.squish
  end

  def down
    drop_table :job_histories
  end
end
