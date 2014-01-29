class SetUserIdentitiesUrlToNotNull < ActiveRecord::Migration
  def change
    execute "
      UPDATE user_identities SET url='https://github.com' WHERE url IS NULL
    ".compact
    change_column :user_identities, :url, :string, null: false
  end
end
