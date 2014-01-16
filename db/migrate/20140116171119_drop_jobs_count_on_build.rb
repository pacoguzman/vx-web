class DropJobsCountOnBuild < ActiveRecord::Migration
  def change
    remove_column :builds, :jobs_count, :integer, null: false, default: 0
  end
end
