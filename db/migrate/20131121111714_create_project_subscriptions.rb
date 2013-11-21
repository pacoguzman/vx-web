class CreateProjectSubscriptions < ActiveRecord::Migration
  def change
    create_table :project_subscriptions do |t|
      t.integer :project_id, null: false
      t.integer :user_id, null: false
      t.boolean :subscribe, null: false, default: true
      t.timestamps
    end

    add_index :project_subscriptions, :project_id
    add_index :project_subscriptions, [:project_id, :user_id], unique: true
  end
end
