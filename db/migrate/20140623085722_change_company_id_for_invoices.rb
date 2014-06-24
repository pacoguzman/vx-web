class ChangeCompanyIdForInvoices < ActiveRecord::Migration
  def change
    remove_column :invoices, :company_id
    add_column :invoices, :company_id, :uuid
    add_index :invoices, :company_id
  end
end
