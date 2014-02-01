class ChangeUserRepoIdOnProjects < ActiveRecord::Migration
  def change
    change_column :projects, :user_repo_id, :integer, null: true
  end
end
