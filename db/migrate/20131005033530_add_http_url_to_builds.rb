class AddHttpUrlToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :http_url, :string
  end
end
