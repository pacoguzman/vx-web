class AddBackOfficeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :back_office, :boolean, default: false
  end
end
