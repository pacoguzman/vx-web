class AddJobsCountToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :jobs_count, :integer, null: false, default: 0
  end
end
