class Api::GithubReposController < Api::BaseController
  respond_to :json

  def index
    respond_with(@github_repos = current_user.github_repos)
  end
end
