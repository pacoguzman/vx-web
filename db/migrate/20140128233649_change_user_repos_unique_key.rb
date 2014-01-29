class ChangeUserReposUniqueKey < ActiveRecord::Migration
  def change
    #remove_index :user_repos, [:full_name, :identity_id]
    execute "CREATE TEMP SEQUENCE the_seq START WITH 2"
    execute "
      UPDATE user_repos
         SET external_id = (-1 * nextval('the_seq'))
       WHERE external_id = -1
    ".compact
    execute "DROP SEQUENCE the_seq"
    add_index :user_repos, [:identity_id, :external_id], unique: true
  end
end
