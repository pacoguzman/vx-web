class Add < ActiveRecord::Migration
  def change
    add_column :builds, :author_email, :string
  end
end
