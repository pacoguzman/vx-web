class AddUuidPkToJobs < ActiveRecord::Migration
  def up
    execute %{
      ALTER TABLE jobs ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;

      ALTER TABLE job_logs ADD COLUMN _job_id uuid ;

      UPDATE job_logs
        SET _job_id = jobs._id
        FROM jobs
        WHERE job_logs.job_id = jobs.id ;

      ALTER TABLE job_logs ALTER COLUMN _job_id SET NOT NULL ;

      ALTER TABLE jobs DROP COLUMN id CASCADE ;
      ALTER TABLE jobs RENAME COLUMN _id TO id ;
      ALTER TABLE jobs ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS jobs_id_seq ;

      ALTER TABLE job_logs DROP COLUMN job_id ;
      ALTER TABLE job_logs RENAME COLUMN _job_id TO job_id ;

      ALTER TABLE job_logs ADD CONSTRAINT job_logs_job_id_fkey
        FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE RESTRICT ;
    }.squish

    add_index :job_logs, [:job_id]
  end

  def down
    execute %{
      CREATE SEQUENCE jobs_id_seq ;
      ALTER TABLE jobs ADD COLUMN _id integer DEFAULT nextval('jobs_id_seq'::regclass) NOT NULL ;

      ALTER TABLE job_logs ADD COLUMN _job_id integer ;

      UPDATE job_logs
        SET _job_id = jobs._id
        FROM jobs
        WHERE job_logs.job_id = jobs.id ;

      ALTER TABLE job_logs ALTER COLUMN _job_id SET NOT NULL ;

      ALTER TABLE jobs DROP COLUMN id CASCADE ;
      ALTER TABLE jobs RENAME COLUMN _id TO id ;
      ALTER TABLE jobs ADD PRIMARY KEY(id) ;

      ALTER TABLE job_logs DROP COLUMN job_id ;
      ALTER TABLE job_logs RENAME COLUMN _job_id TO job_id ;

      ALTER TABLE job_logs ADD CONSTRAINT job_logs_job_id_fkey
        FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE RESTRICT ;
    }.squish

    add_index :job_logs, [:job_id]
  end
end
