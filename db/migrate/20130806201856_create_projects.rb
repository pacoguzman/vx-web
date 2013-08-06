class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name,      null: false
      t.string :url,       null: false
      t.text   :provider,  null: false
      t.text   :description

      t.timestamps
    end
  end
end
