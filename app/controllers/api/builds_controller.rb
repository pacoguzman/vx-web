class ::Api::BuildsController < ::Api::BaseController

  respond_to :json
  skip_before_filter :authorize_user, if: :show_build_status_with_token

  def index
    respond_with(@builds = project.builds.limit(20))
  end

  def show
    respond_with build
  end

  def queued
    respond_with(@builds = Build.pending.limit(20))
  end

  def sha
    build = ::Build.find_by!(sha: params[:sha])
    respond_with build
  end

  def restart
    if build.restart
      respond_with build, location: [:api, build]
    else
      head :unprocessable_entity
    end
  end

  private

    def project
      @project ||= ::Project.find params[:project_id]
    end

    def build
      @build ||= ::Build.find params[:id]
    end

    def show_build_status_with_token
      correct_action = action_name.to_s.in?(%w(sha show))
      correct_token = Project.where(token: params[:token]).exists?
      correct_action && correct_token
    end

end
