class AddLastBuildToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :last_build_id,          :integer
    add_column :projects, :last_build_status_name, :integer
    add_column :projects, :last_build_at,          :datetime
  end
end
