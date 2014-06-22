class AddRoleToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :role, :string, null: false, default: "developer"
  end
end
