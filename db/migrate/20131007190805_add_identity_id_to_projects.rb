class AddIdentityIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :identity_id, :integer
  end
end
