class ChangeBuildMessageLength < ActiveRecord::Migration
  def change
    change_column :builds, :message, :text
  end
end
