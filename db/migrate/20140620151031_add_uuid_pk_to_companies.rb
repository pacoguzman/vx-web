class AddUuidPkToCompanies < ActiveRecord::Migration
  def up
    enable_extension 'uuid-ossp'

    execute %{

      ALTER TABLE companies ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;

      ALTER TABLE invites ADD COLUMN _company_id uuid ;
      ALTER TABLE projects ADD COLUMN _company_id uuid ;
      ALTER TABLE user_companies ADD COLUMN _company_id uuid ;
      ALTER TABLE user_repos ADD COLUMN _company_id uuid ;

      UPDATE invites
        SET _company_id = companies._id
        FROM companies
        WHERE invites.company_id = companies.id ;

      UPDATE projects
        SET _company_id = companies._id
        FROM companies
        WHERE projects.company_id = companies.id ;

      UPDATE user_companies
        SET _company_id = companies._id
        FROM companies
        WHERE user_companies.company_id = companies.id ;

      UPDATE user_repos
        SET _company_id = companies._id
        FROM companies
        WHERE user_repos.company_id = companies.id ;

      ALTER TABLE invites ALTER COLUMN _company_id SET NOT NULL ;
      ALTER TABLE projects ALTER COLUMN _company_id SET NOT NULL ;
      ALTER TABLE user_companies ALTER COLUMN _company_id SET NOT NULL ;
      ALTER TABLE user_repos ALTER COLUMN _company_id SET NOT NULL ;

      ALTER TABLE companies DROP COLUMN id ;
      ALTER TABLE companies RENAME COLUMN _id TO id ;
      ALTER TABLE companies ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS companies_id_seq ;

      ALTER TABLE invites DROP COLUMN company_id ;
      ALTER TABLE invites RENAME COLUMN _company_id TO company_id ;

      ALTER TABLE projects DROP COLUMN company_id ;
      ALTER TABLE projects RENAME COLUMN _company_id TO company_id ;

      ALTER TABLE user_companies DROP COLUMN company_id ;
      ALTER TABLE user_companies RENAME COLUMN _company_id TO company_id ;

      ALTER TABLE user_repos DROP COLUMN company_id ;
      ALTER TABLE user_repos RENAME COLUMN _company_id TO company_id ;

    }.compact

  end

  def down

    execute %{
      CREATE SEQUENCE companies_id_seq ;
      ALTER TABLE companies ADD COLUMN _id integer DEFAULT nextval('companies_id_seq'::regclass) NOT NULL ;

      ALTER TABLE invites ADD COLUMN _company_id integer ;
      ALTER TABLE projects ADD COLUMN _company_id integer ;
      ALTER TABLE user_companies ADD COLUMN _company_id integer ;
      ALTER TABLE user_repos ADD COLUMN _company_id integer ;

      UPDATE invites
        SET _company_id = companies._id
        FROM companies
        WHERE invites.company_id = companies.id ;

      UPDATE projects
        SET _company_id = companies._id
        FROM companies
        WHERE projects.company_id = companies.id ;

      UPDATE user_companies
        SET _company_id = companies._id
        FROM companies
        WHERE user_companies.company_id = companies.id ;

      UPDATE user_repos
        SET _company_id = companies._id
        FROM companies
        WHERE user_repos.company_id = companies.id ;

      ALTER TABLE invites ALTER COLUMN _company_id SET NOT NULL ;
      ALTER TABLE projects ALTER COLUMN _company_id SET NOT NULL ;
      ALTER TABLE user_companies ALTER COLUMN _company_id SET NOT NULL ;
      ALTER TABLE user_repos ALTER COLUMN _company_id SET NOT NULL ;

      ALTER TABLE companies DROP COLUMN id ;
      ALTER TABLE companies RENAME COLUMN _id TO id ;
      ALTER TABLE companies ADD PRIMARY KEY(id) ;

      ALTER TABLE invites DROP COLUMN company_id ;
      ALTER TABLE invites RENAME COLUMN _company_id TO company_id ;

      ALTER TABLE projects DROP COLUMN company_id ;
      ALTER TABLE projects RENAME COLUMN _company_id TO company_id ;

      ALTER TABLE user_companies DROP COLUMN company_id ;
      ALTER TABLE user_companies RENAME COLUMN _company_id TO company_id ;

      ALTER TABLE user_repos DROP COLUMN company_id ;
      ALTER TABLE user_repos RENAME COLUMN _company_id TO company_id ;

    }.compact

  end
end
