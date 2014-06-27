class AddUuidPkToUserRepos < ActiveRecord::Migration
  def up
    execute %{
      ALTER TABLE user_repos ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;

      ALTER TABLE projects ADD COLUMN _user_repo_id uuid ;

      UPDATE projects
        SET _user_repo_id = user_repos._id
        FROM user_repos
        WHERE projects.user_repo_id = user_repos.id ;

      ALTER TABLE projects ALTER COLUMN _user_repo_id SET NOT NULL ;

      ALTER TABLE user_repos DROP COLUMN id CASCADE ;
      ALTER TABLE user_repos RENAME COLUMN _id TO id ;
      ALTER TABLE user_repos ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS user_repos_id_seq ;

      ALTER TABLE projects DROP COLUMN user_repo_id ;
      ALTER TABLE projects RENAME COLUMN _user_repo_id TO user_repo_id ;

      ALTER TABLE projects ADD CONSTRAINT projects_user_repo_id_fkey
        FOREIGN KEY (user_repo_id) REFERENCES user_repos(id) ON DELETE RESTRICT ;
    }.squish
  end

  def down
    execute %{
      CREATE SEQUENCE user_repos_id_seq ;

      ALTER TABLE user_repos ADD COLUMN _id integer DEFAULT nextval('user_repos_id_seq'::regclass) NOT NULL ;

      ALTER TABLE projects ADD COLUMN _user_repo_id integer ;

      UPDATE projects
        SET _user_repo_id = user_repos._id
        FROM user_repos
        WHERE projects.user_repo_id = user_repos.id ;

      ALTER TABLE user_repos DROP COLUMN id CASCADE ;
      ALTER TABLE user_repos RENAME COLUMN _id TO id ;
      ALTER TABLE user_repos ADD PRIMARY KEY(id) ;

      ALTER TABLE projects DROP COLUMN user_repo_id ;
      ALTER TABLE projects RENAME COLUMN _user_repo_id TO user_repo_id ;
    }.squish
  end
end
