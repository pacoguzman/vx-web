class Api::GithubReposController < Api::BaseController

  def index
    respond_to do |want|
      want.json { render json: github_repos }
    end
  end

  def subscribe
    github_repo.subscribe

    respond_to do |want|
      want.json { render json: github_repo }
    end
  end

  def unsubscribe
    github_repo.unsubscribe
    respond_to do |want|
      want.json { render json: github_repo }
    end
  end

  def sync
    current_user.sync_github_repos!
    respond_to do |want|
      want.json { render json: github_repos }
    end
  end

  private

    def github_repo
      @github_repo ||= current_user.github_repos.find params[:id]
    end

    def github_repos
      @github_repos ||= current_user.github_repos
    end

end
