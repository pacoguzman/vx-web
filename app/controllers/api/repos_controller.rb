class Api::GithubReposController < Api::BaseController

  respond_to :json

  def index
    respond_with(github_repos, each_serializer: GithubRepoSerializer)
  end

  def sync
    current_user.sync_github_repos!
    respond_with(github_repos, each_serializer: GithubRepoSerializer, location: nil)
  end

  def subscribe
    github_repo.subscribe do |new_project|
      new_project.publish :created
    end
    respond_with(github_repo, serializer: GithubRepoSerializer, location: nil)
  end

  def unsubscribe
    github_repo.unsubscribe
    respond_with(github_repo, serializer: GithubRepoSerializer, location: nil)
  end

  private

    def github_repo
      @github_repo ||= current_user.github_repos.find params[:id]
    end

    def github_repos
      @github_repos ||= current_user.github_repos
    end

end
