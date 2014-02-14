class AddTypeToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :type, :string
  end
end
