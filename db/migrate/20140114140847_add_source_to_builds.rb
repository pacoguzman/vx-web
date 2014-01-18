class AddSourceToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :source, :text
  end
end
