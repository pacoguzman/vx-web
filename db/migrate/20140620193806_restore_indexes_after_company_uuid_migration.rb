class RestoreIndexesAfterCompanyUuidMigration < ActiveRecord::Migration
  def change
    add_index :projects, [:company_id, :name], unique: true
    add_index :user_companies, [:user_id, :company_id], unique: true
    add_index "user_repos", ["company_id", "full_name", "identity_id"], unique: true
    add_index "user_repos", ["company_id", "identity_id", "external_id"], unique: true
  end
end
