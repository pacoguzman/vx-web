class NameUserIndentityIdToIdentityIdOnUserRepos < ActiveRecord::Migration
  def change
    rename_column :user_repos, :user_identity_id, :identity_id
  end
end
