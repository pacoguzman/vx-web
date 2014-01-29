class ChangeUserIdentitiesUniqueKey < ActiveRecord::Migration
  def change
    remove_index :user_identities, [:user_id, :provider]
    add_index :user_identities, [:user_id, :provider, :uid, :url], unique: true
  end
end
