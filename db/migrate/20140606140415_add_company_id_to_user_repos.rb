class AddCompanyIdToUserRepos < ActiveRecord::Migration
  def up
    add_column :user_repos, :company_id, :integer
    execute %{
      UPDATE user_repos SET company_id = (SELECT companies.id FROM companies LIMIT 1)
    }.compact

    remove_index :user_repos, [:full_name, :identity_id]
    add_index :user_repos, [:company_id, :full_name, :identity_id],
      unique: true

    remove_index :user_repos, [:identity_id, :external_id]
    add_index :user_repos, [:company_id, :identity_id, :external_id],
      unique: true
  end

  def down
    remove_column :user_repos, :company_id

    add_index :user_repos, [:full_name, :identity_id], unique: true
    add_index :user_repos, [:identity_id, :external_id], unique: true
  end
end
