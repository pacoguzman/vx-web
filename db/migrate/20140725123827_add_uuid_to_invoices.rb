class AddUuidToInvoices < ActiveRecord::Migration
  def up
    execute %{
      ALTER TABLE invoices ADD COLUMN _id uuid DEFAULT uuid_generate_v4() NOT NULL ;
      ALTER TABLE invoices DROP COLUMN id ;
      ALTER TABLE invoices RENAME COLUMN _id TO id ;
      ALTER TABLE invoices ADD PRIMARY KEY(id) ;
      DROP SEQUENCE IF EXISTS invoices_id_seq ;

      ALTER TABLE invoices ADD CONSTRAINT invoices_company_id_fkey
        FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE RESTRICT ;
    }.squish
    remove_column :invoices, :started_at
    remove_column :invoices, :finished_at

    remove_column :invoices, :state
    add_column :invoices, :state, :integer, null: false, default: 0

    change_column :invoices, :amount, :integer, null: false
    change_column :invoices, :company_id, :uuid, null: false
  end

  def down
    execute %{
      ALTER TABLE invoices DROP CONSTRAINT invoices_company_id_fkey ;

      CREATE SEQUENCE invoices_id_seq ;
      ALTER TABLE invoices ADD COLUMN _id integer DEFAULT nextval('invoices_id_seq'::regclass) NOT NULL ;

      ALTER TABLE invoices DROP COLUMN id ;
      ALTER TABLE invoices RENAME COLUMN _id TO id ;
      ALTER TABLE invoices ADD PRIMARY KEY(id) ;
    }.squish
    add_column :invoices, :started_at, :datetime, null: false
    add_column :invoices, :finished_at, :datetime, null: false

    remove_column :invoices, :state
    add_column :invoices, :state, :string, null: false
    change_column :invoices, :amount, :decimal, null: false
    change_column :invoices, :company_id, :uuid, null: true
  end
end
