class ChangeCompanyIdForInvoices < ActiveRecord::Migration
  def up
    remove_column :invoices, :company_id
    add_column :invoices, :company_id, :uuid
    add_index :invoices, :company_id
  end

  def down
    remove_column :invoices, :company_id
    add_column :invoices, :company_id, :id
    add_index :invoices, :company_id
  end
end
