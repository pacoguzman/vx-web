class AddUserIdentityIdToUserRepos < ActiveRecord::Migration
  def change
    add_column :user_repos, :user_identity_id, :integer
    execute "
      UPDATE user_repos
        SET user_identity_id = sub.id
        FROM (
          SELECT id, user_id
          FROM user_identities
          WHERE provider = 'github'
          GROUP BY user_id, id
        ) sub
        WHERE sub.user_id = user_repos.user_id
    "
    change_column :user_repos, :user_identity_id, :integer, null: false
  end
end
