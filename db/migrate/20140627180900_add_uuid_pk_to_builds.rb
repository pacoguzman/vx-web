class AddUuidPkToBuilds < ActiveRecord::Migration
  def up
    execute %{
      ALTER TABLE builds ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;

      ALTER TABLE jobs ADD COLUMN _build_id uuid ;

      UPDATE jobs
        SET _build_id = builds._id
        FROM builds
        WHERE jobs.build_id = builds.id ;

      ALTER TABLE jobs ALTER COLUMN _build_id SET NOT NULL ;

      ALTER TABLE builds DROP COLUMN id CASCADE ;
      ALTER TABLE builds RENAME COLUMN _id TO id ;
      ALTER TABLE builds ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS builds_id_seq ;

      ALTER TABLE jobs DROP COLUMN build_id ;
      ALTER TABLE jobs RENAME COLUMN _build_id TO build_id ;

      ALTER TABLE jobs ADD CONSTRAINT jobs_build_id_fkey
        FOREIGN KEY (build_id) REFERENCES builds(id) ON DELETE RESTRICT ;
    }.squish

    add_index :jobs, [:build_id, :number], unique: true
  end

  def down
    execute %{

      CREATE SEQUENCE builds_id_seq ;
      ALTER TABLE builds ADD COLUMN _id integer DEFAULT nextval('builds_id_seq'::regclass) NOT NULL ;

      ALTER TABLE jobs ADD COLUMN _build_id integer ;

      UPDATE jobs
        SET _build_id = builds._id
        FROM builds
        WHERE jobs.build_id = builds.id ;

      ALTER TABLE jobs ALTER COLUMN _build_id SET NOT NULL ;

      ALTER TABLE builds DROP COLUMN id CASCADE ;
      ALTER TABLE builds RENAME COLUMN _id TO id ;
      ALTER TABLE builds ADD PRIMARY KEY(id) ;

      ALTER TABLE jobs DROP COLUMN build_id ;
      ALTER TABLE jobs RENAME COLUMN _build_id TO build_id ;

      ALTER TABLE jobs ADD CONSTRAINT jobs_build_id_fkey
        FOREIGN KEY (build_id) REFERENCES builds(id) ON DELETE RESTRICT ;
    }.squish

    add_index :jobs, [:build_id, :number], unique: true
  end
end
