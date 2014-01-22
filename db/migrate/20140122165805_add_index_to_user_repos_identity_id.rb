class AddIndexToUserReposIdentityId < ActiveRecord::Migration
  def change
    add_index :user_repos, [:full_name, :identity_id], unique: true
  end
end
