class AddUuidPkToProjects < ActiveRecord::Migration
  def up
    execute %{
      ALTER TABLE projects ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;

      ALTER TABLE builds ADD COLUMN _project_id uuid ;
      ALTER TABLE cached_files ADD COLUMN _project_id uuid ;
      ALTER TABLE project_subscriptions ADD COLUMN _project_id uuid ;

      UPDATE builds
        SET _project_id = projects._id
        FROM projects
        WHERE builds.project_id = projects.id ;

      UPDATE cached_files
        SET _project_id = projects._id
        FROM projects
        WHERE cached_files.project_id = projects.id ;

      UPDATE project_subscriptions
        SET _project_id = projects._id
        FROM projects
        WHERE project_subscriptions.project_id = projects.id ;

      ALTER TABLE builds ALTER COLUMN _project_id SET NOT NULL ;
      ALTER TABLE cached_files ALTER COLUMN _project_id SET NOT NULL ;
      ALTER TABLE project_subscriptions ALTER COLUMN _project_id SET NOT NULL ;

      ALTER TABLE projects DROP COLUMN id CASCADE ;
      ALTER TABLE projects RENAME COLUMN _id TO id ;
      ALTER TABLE projects ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS projects_id_seq ;

      ALTER TABLE builds DROP COLUMN project_id ;
      ALTER TABLE builds RENAME COLUMN _project_id TO project_id ;
      ALTER TABLE cached_files DROP COLUMN project_id ;
      ALTER TABLE cached_files RENAME COLUMN _project_id TO project_id ;
      ALTER TABLE project_subscriptions DROP COLUMN project_id ;
      ALTER TABLE project_subscriptions RENAME COLUMN _project_id TO project_id ;

      ALTER TABLE builds ADD CONSTRAINT builds_project_id_fkey
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT ;
      ALTER TABLE cached_files ADD CONSTRAINT cached_files_project_id_fkey
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT ;
      ALTER TABLE project_subscriptions ADD CONSTRAINT project_subscriptions_project_id_fkey
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT ;
    }.squish

    add_index :builds, [:project_id, :number], unique: true
    add_index :cached_files, [:project_id, :file_name], unique: true
    add_index :project_subscriptions, [:project_id, :user_id], unique: true

    remove_columns :projects, :last_build_id, :last_build_status_name, :last_build_at
  end

  def down
    execute %{
      CREATE SEQUENCE projects_id_seq ;
      ALTER TABLE projects ADD COLUMN _id integer DEFAULT nextval('projects_id_seq'::regclass) NOT NULL ;

      ALTER TABLE builds ADD COLUMN _project_id integer ;
      ALTER TABLE cached_files ADD COLUMN _project_id integer ;
      ALTER TABLE project_subscriptions ADD COLUMN _project_id integer ;

      UPDATE builds
        SET _project_id = projects._id
        FROM projects
        WHERE builds.project_id = projects.id ;

      UPDATE cached_files
        SET _project_id = projects._id
        FROM projects
        WHERE cached_files.project_id = projects.id ;

      UPDATE project_subscriptions
        SET _project_id = projects._id
        FROM projects
        WHERE project_subscriptions.project_id = projects.id ;

      ALTER TABLE builds ALTER COLUMN _project_id SET NOT NULL ;
      ALTER TABLE cached_files ALTER COLUMN _project_id SET NOT NULL ;
      ALTER TABLE project_subscriptions ALTER COLUMN _project_id SET NOT NULL ;

      ALTER TABLE projects DROP COLUMN id CASCADE ;
      ALTER TABLE projects RENAME COLUMN _id TO id ;
      ALTER TABLE projects ADD PRIMARY KEY(id) ;

      ALTER TABLE builds DROP COLUMN project_id ;
      ALTER TABLE builds RENAME COLUMN _project_id TO project_id ;

      ALTER TABLE cached_files DROP COLUMN project_id ;
      ALTER TABLE cached_files RENAME COLUMN _project_id TO project_id ;

      ALTER TABLE project_subscriptions DROP COLUMN project_id ;
      ALTER TABLE project_subscriptions RENAME COLUMN _project_id TO project_id ;

      ALTER TABLE builds ADD CONSTRAINT builds_project_id_fkey
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT ;
      ALTER TABLE cached_files ADD CONSTRAINT cached_files_project_id_fkey
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT ;
      ALTER TABLE project_subscriptions ADD CONSTRAINT project_subscriptions_project_id_fkey
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT ;
    }.squish

    add_index :builds, [:project_id, :number], unique: true
    add_index :cached_files, [:project_id, :file_name], unique: true
    add_index :project_subscriptions, [:project_id, :user_id], unique: true

    add_column :projects, :last_build_id, :integer
    add_column :projects, :last_build_status_name, :string
    add_column :projects, :last_build_at, :datetime
  end
end
