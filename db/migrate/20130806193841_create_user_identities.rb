class CreateUserIdentities < ActiveRecord::Migration
  def change
    create_table :user_identities do |t|
      t.integer :user_id,  null: false
      t.string  :provider, null: false
      t.string  :token,    null: false
      t.string  :uid,      null: false
      t.string  :login,    null: false

      t.timestamps
    end
    add_index :user_identities, [:user_id, :provider], unique: true
  end
end
