class AddFkToCompanies < ActiveRecord::Migration
  def up
    execute %{

      DELETE FROM job_logs
        WHERE job_logs.job_id NOT IN (
          SELECT jobs.id FROM jobs
        ) ;

      ALTER TABLE invites ADD CONSTRAINT invites_company_id_fkey
        FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT ;

      ALTER TABLE projects ADD CONSTRAINT projects_company_id_fkey
        FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT ;

      ALTER TABLE user_companies ADD CONSTRAINT user_companies_company_id_fkey
        FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT ;

      ALTER TABLE user_repos ADD CONSTRAINT user_repos_company_id_fkey
        FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT ;

      ALTER TABLE builds ADD CONSTRAINT builds_project_id_fkey
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT ;

      ALTER TABLE jobs ADD CONSTRAINT jobs_build_id_fkey
        FOREIGN KEY (build_id) REFERENCES builds(id) ON DELETE RESTRICT ;

      ALTER TABLE job_logs ADD CONSTRAINT job_logs_job_id_fkey
        FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE RESTRICT ;
    }.compact
  end

  def down
    execute %{
      ALTER TABLE invites DROP CONSTRAINT invites_company_id_fkey ;
      ALTER TABLE projects DROP CONSTRAINT projects_company_id_fkey ;
      ALTER TABLE user_companies DROP CONSTRAINT user_companies_company_id_fkey ;
      ALTER TABLE user_repos DROP CONSTRAINT user_repos_company_id_fkey ;

      ALTER TABLE builds DROP CONSTRAINT builds_project_id_fkey ;
      ALTER TABLE jobs DROP CONSTRAINT jobs_build_id_fkey ;
      ALTER TABLE job_logs DROP CONSTRAINT job_logs_job_id_fkey ;
    }
  end
end
