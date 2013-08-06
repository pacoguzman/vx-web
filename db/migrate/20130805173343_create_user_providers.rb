class CreateUserProviders < ActiveRecord::Migration
  def change
    create_table :user_providers do |t|
      t.integer :user_id,  null: false
      t.string  :provider, null: false
      t.string  :uid,      null: false
      t.timestamps
    end
  end
end
