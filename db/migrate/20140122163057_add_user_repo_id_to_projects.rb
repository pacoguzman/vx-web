class AddUserRepoIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :user_repo_id, :integer
    execute "
      UPDATE projects
        SET user_repo_id = sub.id
        FROM (
          SELECT user_repos.id,
                 user_identities.id AS identity_id,
                 user_repos.full_name
            FROM user_repos
            INNER JOIN user_identities ON
              user_identities.id = user_repos.identity_id
            GROUP BY user_repos.id, user_repos.full_name, user_identities.id
        ) sub
        WHERE
          sub.identity_id = projects.identity_id AND
          sub.full_name = projects.name
    ".gsub(/\n/, ' ').gsub(/ +/, ' ')
    change_column :projects, :user_repo_id, :integer, null: false
  end
end
