class AddRoleToUserCompanies < ActiveRecord::Migration
  def up
    add_column :user_companies, :role, :string

    execute "UPDATE user_companies SET role = 'developer'"
    execute %{
      UPDATE user_companies SET role = 'admin'
      FROM (
        SELECT MIN(user_id) AS user_id, company_id FROM user_companies GROUP BY company_id
      ) AS q
      WHERE q.user_id = user_companies.user_id AND q.company_id = user_companies.company_id
    }.compact

    change_column :user_companies, :role, :string, null: false
  end

  def down
    remove_column :user_companies, :role
  end
end
