class RemoveJobsCountAndMatrixFromBuild < ActiveRecord::Migration
  def change
    remove_columns :builds, :jobs_count, :matrix
  end
end
