class CreateGithubRepos < ActiveRecord::Migration
  def change
    create_table :github_repos do |t|
      t.integer :user_id,      null: false
      t.string  :organization_login
      t.string  :full_name,    null: false
      t.boolean :is_private,   null: false
      t.string  :ssh_url,      null: false
      t.string  :html_url,     null: false

      t.timestamps
    end
    add_index :github_repos, [:user_id, :full_name], unique: true
  end
end
