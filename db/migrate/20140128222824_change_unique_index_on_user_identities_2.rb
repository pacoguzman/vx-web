class ChangeUniqueIndexOnUserIdentities2 < ActiveRecord::Migration
  def change
    remove_index :user_identities, [:user_id, :provider, :uid, :url]
    add_index :user_identities, [:user_id, :provider, :url], unique: true
  end
end
