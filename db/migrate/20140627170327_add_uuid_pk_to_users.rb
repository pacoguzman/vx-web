class AddUuidPkToUsers < ActiveRecord::Migration
  def up

    execute %{
      ALTER TABLE users ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;

      ALTER TABLE project_subscriptions ADD COLUMN _user_id uuid ;
      ALTER TABLE user_companies ADD COLUMN _user_id uuid ;
      ALTER TABLE user_identities ADD COLUMN _user_id uuid ;

      UPDATE project_subscriptions
        SET _user_id = users._id
        FROM users
        WHERE project_subscriptions.user_id = users.id ;

      UPDATE user_companies
        SET _user_id = users._id
        FROM users
        WHERE user_companies.user_id = users.id ;

      UPDATE user_identities
        SET _user_id = users._id
        FROM users
        WHERE user_identities.user_id = users.id ;

      ALTER TABLE project_subscriptions ALTER COLUMN _user_id SET NOT NULL ;
      ALTER TABLE user_companies ALTER COLUMN _user_id SET NOT NULL ;
      ALTER TABLE user_identities ALTER COLUMN _user_id SET NOT NULL ;

      ALTER TABLE users DROP COLUMN id ;
      ALTER TABLE users RENAME COLUMN _id TO id ;
      ALTER TABLE users ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS users_id_seq ;

      ALTER TABLE project_subscriptions DROP COLUMN user_id ;
      ALTER TABLE project_subscriptions RENAME COLUMN _user_id TO user_id ;

      ALTER TABLE user_companies DROP COLUMN user_id ;
      ALTER TABLE user_companies RENAME COLUMN _user_id TO user_id ;

      ALTER TABLE user_identities DROP COLUMN user_id ;
      ALTER TABLE user_identities RENAME COLUMN _user_id TO user_id ;

      ALTER TABLE project_subscriptions ADD CONSTRAINT project_subscriptions_user_id_fkey
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ;

      ALTER TABLE user_companies ADD CONSTRAINT user_companies_user_id_fkey
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ;

      ALTER TABLE user_identities ADD CONSTRAINT user_identities_user_id_fkey
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ;
    }.squish

    add_index :project_subscriptions, [:project_id, :user_id], unique: true
    add_index :user_companies, [:user_id, :company_id], unique: true
    add_index :user_identities, [:user_id, :provider, :url], unique: true

  end

  def down
    execute %{
      ALTER TABLE project_subscriptions DROP CONSTRAINT project_subscriptions_user_id_fkey ;
      ALTER TABLE user_companies DROP CONSTRAINT user_companies_user_id_fkey ;
      ALTER TABLE user_identities DROP CONSTRAINT user_identities_user_id_fkey ;

      CREATE SEQUENCE users_id_seq ;
      ALTER TABLE users ADD COLUMN _id integer DEFAULT nextval('users_id_seq'::regclass) NOT NULL ;

      ALTER TABLE project_subscriptions ADD COLUMN _user_id integer ;
      ALTER TABLE user_companies ADD COLUMN _user_id integer ;
      ALTER TABLE user_identities ADD COLUMN _user_id integer ;

      UPDATE project_subscriptions
        SET _user_id = users._id
        FROM users
        WHERE project_subscriptions.user_id = users.id ;

      UPDATE user_companies
        SET _user_id = users._id
        FROM users
        WHERE user_companies.user_id = users.id ;

      UPDATE user_identities
        SET _user_id = users._id
        FROM users
        WHERE user_identities.user_id = users.id ;

      ALTER TABLE project_subscriptions ALTER COLUMN _user_id SET NOT NULL ;
      ALTER TABLE user_companies ALTER COLUMN _user_id SET NOT NULL ;
      ALTER TABLE user_identities ALTER COLUMN _user_id SET NOT NULL ;

      ALTER TABLE users DROP COLUMN id ;
      ALTER TABLE users RENAME COLUMN _id TO id ;
      ALTER TABLE users ADD PRIMARY KEY(id) ;

      ALTER TABLE project_subscriptions DROP COLUMN user_id ;
      ALTER TABLE project_subscriptions RENAME COLUMN _user_id TO user_id ;

      ALTER TABLE user_companies DROP COLUMN user_id ;
      ALTER TABLE user_companies RENAME COLUMN _user_id TO user_id ;

      ALTER TABLE user_identities DROP COLUMN user_id ;
      ALTER TABLE user_identities RENAME COLUMN _user_id TO user_id ;
    }.squish

    add_index :project_subscriptions, [:project_id, :user_id], unique: true
    add_index :user_companies, [:user_id, :company_id], unique: true
    add_index :user_identities, [:user_id, :provider, :url], unique: true
  end
end
