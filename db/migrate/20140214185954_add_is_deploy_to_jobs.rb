class AddIsDeployToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :kind, :string
  end
end
