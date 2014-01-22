class RenameGithubRepos < ActiveRecord::Migration
  def change
    rename_table :github_repos, :user_repos
  end
end
