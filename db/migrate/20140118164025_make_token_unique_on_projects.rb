class MakeTokenUniqueOnProjects < ActiveRecord::Migration
  def change
    add_index :projects, :token, unique: true
  end
end
