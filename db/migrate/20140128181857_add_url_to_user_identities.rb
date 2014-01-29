class AddUrlToUserIdentities < ActiveRecord::Migration
  def change
    add_column :user_identities, :url, :string
  end
end
