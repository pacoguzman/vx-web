class CreateUserCompanies < ActiveRecord::Migration
  def change
    create_table :user_companies do |t|
      t.integer :user_id,    null: false
      t.integer :company_id, null: false
      t.integer :default,    null: false, default: 0

      t.timestamps
    end
    add_index :user_companies, [:user_id, :company_id], unique: true
  end
end
