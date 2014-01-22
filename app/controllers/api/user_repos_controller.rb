class Api::UserReposController < Api::BaseController

  respond_to :json

  def index
    respond_with(user_repos, each_serializer: UserRepoSerializer)
  end

  def sync
    current_user.sync_repos
    respond_with(user_repos, each_serializer: UserRepoSerializer, location: nil)
  end

  def subscribe
    user_repo.subscribe do |new_project|
      new_project.publish :created
    end
    respond_with(user_repo, serializer: UserRepoSerializer, location: nil)
  end

  def unsubscribe
    user_repo.unsubscribe
    respond_with(user_repo, serializer: UserRepoSerializer, location: nil)
  end

  private

    def user_repo
      @user_repo ||= current_user.user_repos.find params[:id]
    end

    def user_repos
      @user_repos ||= current_user.user_repos
    end

end
