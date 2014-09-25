class AddStatusToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :status, :integer, null: false, default: 0
  end
end
