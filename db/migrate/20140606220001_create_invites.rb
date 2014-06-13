class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :company_id, null: false
      t.string  :token,      null: false
      t.string  :email,      null: false

      t.timestamps
    end
  end
end
