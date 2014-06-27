class AddUuidPkToUserIdentities < ActiveRecord::Migration
  def up
    execute %{
      ALTER TABLE user_identities ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;

      ALTER TABLE user_repos ADD COLUMN _identity_id uuid ;

      UPDATE user_repos
        SET _identity_id = user_identities._id
        FROM user_identities
        WHERE user_repos.identity_id = user_identities.id ;

      ALTER TABLE user_repos ALTER COLUMN _identity_id SET NOT NULL ;

      ALTER TABLE user_identities DROP COLUMN id CASCADE ;
      ALTER TABLE user_identities RENAME COLUMN _id TO id ;
      ALTER TABLE user_identities ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS user_identities_id_seq ;

      ALTER TABLE user_repos DROP COLUMN identity_id ;
      ALTER TABLE user_repos RENAME COLUMN _identity_id TO identity_id ;

      ALTER TABLE user_repos ADD CONSTRAINT user_repos_identity_id_fkey
        FOREIGN KEY (identity_id) REFERENCES user_identities(id) ON DELETE RESTRICT ;
    }.squish

    add_index :user_repos, [:company_id, :full_name, :identity_id], unique: true
    add_index :user_repos, [:company_id, :identity_id, :external_id], unique: true
  end

  def down
    execute %{
      CREATE SEQUENCE user_identities_id_seq ;
      ALTER TABLE user_identities ADD COLUMN _id integer DEFAULT nextval('user_identities_id_seq'::regclass) NOT NULL ;

      ALTER TABLE user_repos ADD COLUMN _identity_id integer ;

      UPDATE user_repos
        SET _identity_id = user_identities._id
        FROM user_identities
        WHERE user_repos.identity_id = user_identities.id ;

      ALTER TABLE user_repos ALTER COLUMN _identity_id SET NOT NULL ;

      ALTER TABLE user_identities DROP COLUMN id CASCADE ;
      ALTER TABLE user_identities RENAME COLUMN _id TO id ;
      ALTER TABLE user_identities ADD PRIMARY KEY(id) ;

      ALTER TABLE user_repos DROP COLUMN identity_id ;
      ALTER TABLE user_repos RENAME COLUMN _identity_id TO identity_id ;

      ALTER TABLE user_repos ADD CONSTRAINT user_repos_identity_id_fkey
        FOREIGN KEY (identity_id) REFERENCES user_identities(id) ON DELETE RESTRICT ;
    }.squish

    add_index :user_repos, [:company_id, :full_name, :identity_id], unique: true
    add_index :user_repos, [:company_id, :identity_id, :external_id], unique: true
  end
end
