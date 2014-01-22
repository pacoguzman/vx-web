class DropOldColumns < ActiveRecord::Migration
  def change
    remove_columns :projects, :provider, :identity_id
    remove_column :user_repos, :user_id
  end
end
