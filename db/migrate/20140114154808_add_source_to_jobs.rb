class AddSourceToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :source, :text
  end
end
