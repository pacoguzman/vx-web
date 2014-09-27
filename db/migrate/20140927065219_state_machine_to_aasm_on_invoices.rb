class StateMachineToAasmOnInvoices < ActiveRecord::Migration
  def up
    rename_column :invoices, :status, :state_machine_status
    add_column :invoices, :status, :string

    Invoice.reset_column_information
    Invoice.where(:state_machine_status => 0).update_all(:status => "pending")
    Invoice.where(:state_machine_status => 1).update_all(:status => "waiting")
    Invoice.where(:state_machine_status => 2).update_all(:status => "paid")
    Invoice.where(:state_machine_status => 3).update_all(:status => "broken")
    Invoice.where(:state_machine_status => 4).update_all(:status => "cancelled")

    remove_column :invoices, :state_machine_status
  end

  def down
    rename_column :invoices, :status, :aasm_status
    add_column :invoices, :status, :integer, :default => 0, :null => false

    Invoice.reset_column_information
    Invoice.where(:aasm_status => "pending").update_all(:status => 0)
    Invoice.where(:aasm_status => "waiting").update_all(:status => 1)
    Invoice.where(:aasm_status => "paid").update_all(:status => 2)
    Invoice.where(:aasm_status => "broken").update_all(:status => 3)
    Invoice.where(:aasm_status => "cancelled").update_all(:status => 4)

    remove_column :invoices, :aasm_status
  end
end
