class AddExternalIdToUserRepos < ActiveRecord::Migration
  def change
    add_column :user_repos, :external_id, :integer
    execute "UPDATE user_repos SET external_id = -1 WHERE external_id IS NULL"
    change_column :user_repos, :external_id, :integer, null: false
  end
end
