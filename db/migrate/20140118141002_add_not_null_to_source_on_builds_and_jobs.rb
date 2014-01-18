class AddNotNullToSourceOnBuildsAndJobs < ActiveRecord::Migration
  def up
    change_column :builds, :source, :text, null: false
    change_column :jobs, :source, :text, null: false
  end

  def down
    change_column :builds, :source, :text, null: true
    change_column :jobs, :source, :text, null: true
  end
end
