class AddRoleToUserCompanies < ActiveRecord::Migration
  def change
    add_column :user_companies, :role, :string

    first_user_company_id = execute('SELECT id FROM user_companies ORDER BY user_companies.id ASC LIMIT 1').first.try(:[], 'id')

    if first_user_company_id
      execute("UPDATE user_companies SET role = 'developer' WHERE id <> '#{ first_user_company_id }'")
      execute("UPDATE user_companies SET role = 'admin' WHERE id = '#{ first_user_company_id }'")
    end

    change_column :user_companies, :role, :string, null: false
  end
end
