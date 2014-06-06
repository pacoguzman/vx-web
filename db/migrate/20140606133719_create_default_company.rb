class CreateDefaultCompany < ActiveRecord::Migration
  def up
    count_companies = select_one("SELECT COUNT(*) AS count_all FROM companies")["count_all"].to_i
    count_users     = select_one("SELECT COUNT(*) AS count_all FROM users")["count_all"].to_i
    if count_companies == 0 && count_users > 0
      cid = execute %{INSERT INTO companies (name) VALUES('default') RETURNING id}
      cid = cid.getvalue(0,0).to_i

      execute %{
        INSERT INTO user_companies(user_id, company_id, "default")
          SELECT id, #{cid}, 1 FROM users
      }.compact
    end
  end

  def down
  end
end
