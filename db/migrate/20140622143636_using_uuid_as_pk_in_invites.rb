class UsingUuidAsPkInInvites < ActiveRecord::Migration
  def up
    execute %{
      ALTER TABLE invites ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;
      ALTER TABLE invites DROP COLUMN id ;

      ALTER TABLE invites RENAME COLUMN _id TO id ;
      ALTER TABLE invites ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS invites_id_seq ;
    }.compact
  end

  def down
    execute %{
      CREATE SEQUENCE invites_id_seq ;
      ALTER TABLE invites ADD COLUMN _id integer DEFAULT nextval('invites_id_seq'::regclass) NOT NULL ;

      ALTER TABLE invites DROP COLUMN id ;
      ALTER TABLE invites RENAME COLUMN _id TO id ;
      ALTER TABLE invites ADD PRIMARY KEY(id) ;
    }
  end
end
