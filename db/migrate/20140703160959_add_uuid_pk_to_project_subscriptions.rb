class AddUuidPkToProjectSubscriptions < ActiveRecord::Migration
  def up
    execute %{
      ALTER TABLE project_subscriptions ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;

      ALTER TABLE project_subscriptions DROP COLUMN id CASCADE ;
      ALTER TABLE project_subscriptions RENAME COLUMN _id TO id ;
      ALTER TABLE project_subscriptions ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS project_subscriptions_id_seq ;
    }.squish
  end

  def down
    execute %{
      CREATE SEQUENCE project_subscriptions_id_seq ;

      ALTER TABLE project_subscriptions ADD COLUMN _id integer DEFAULT nextval('project_subscriptions_id_seq'::regclass) NOT NULL ;

      ALTER TABLE project_subscriptions DROP COLUMN id CASCADE ;
      ALTER TABLE project_subscriptions RENAME COLUMN _id TO id ;
      ALTER TABLE project_subscriptions ADD PRIMARY KEY(id) ;
    }.squish
  end
end
