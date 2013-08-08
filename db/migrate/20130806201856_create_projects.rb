class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string   :name,          null: false
      t.string   :http_url,      null: false
      t.string   :clone_url,     null: false
      t.text     :description
      t.string   :provider
      t.string   :deploy_key,    null: false
      t.string   :token,         null: false

      t.timestamps
    end
    add_index :projects, [:name], unique: true
  end
end
