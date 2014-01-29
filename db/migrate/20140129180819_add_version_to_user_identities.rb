class AddVersionToUserIdentities < ActiveRecord::Migration
  def change
    add_column :user_identities, :version, :string
  end
end
