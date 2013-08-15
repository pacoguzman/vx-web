class AddJobsCountAndMatrixToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :jobs_count, :integer, null: false, default: 0
    add_column :builds, :matrix, :string, array: true, default: []
  end
end
