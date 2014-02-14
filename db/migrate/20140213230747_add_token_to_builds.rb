class AddTokenToBuilds < ActiveRecord::Migration
  def up
    add_column :builds, :token, :string
    execute "UPDATE builds SET token = uuid_in(md5(now()::text)::cstring) WHERE token IS NULL"
    change_column :builds, :token, :string, null: false
  end
end
