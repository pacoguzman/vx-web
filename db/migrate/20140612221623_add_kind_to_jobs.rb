class AddKindToJobs < ActiveRecord::Migration
  def up
    add_column :jobs, :kind, :string
    execute "UPDATE jobs SET kind = 'regular'"
    change_column :jobs, :kind, :string, null: false
  end

  def down
    remove_column :jobs, :kind
  end
end
