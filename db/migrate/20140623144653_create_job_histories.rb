class CreateJobHistories < ActiveRecord::Migration
  def up
    create_table :job_histories, id: false do |t|
      t.uuid     :company_id,   null: false
      t.integer  :duration,     null: false
      t.string   :project_name, null: false
      t.integer  :build_number, null: false
      t.integer  :job_number,   null: false
      t.datetime :created_at,   null: false
    end

    add_index :job_histories, [:company_id, :created_at]

    execute %{
      INSERT INTO job_histories (company_id, duration, project_name, build_number, job_number, created_at)
      SELECT
        projects.company_id AS company_id,
        EXTRACT(EPOCH FROM(jobs.finished_at - jobs.started_at)) AS duration,
        projects.name,
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
