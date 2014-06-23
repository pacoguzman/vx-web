class AddBillingToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :billing_started_at, :datetime
  end
end
