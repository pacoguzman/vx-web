class ::Api::ProjectsController < ::Api::BaseController

  respond_to :json
  skip_before_filter :authorize_user, only: [:key, :rebuild]
  protect_from_forgery except: [:rebuild]

  def index
    projects = current_company.projects.includes([:user, :identity])
    respond_with(projects, serializer: ProjectsSerializer)
  end

  def show
    respond_with(project)
  end

  def key
    project = Project.find params[:id]
    respond_to do |want|
      want.txt {
        render text: project.public_deploy_key, content_type: "text/plain"
      }
    end
  end

  def build_head
    if new_build = project.build_head_commit
      respond_with(new_build, location: [:api, new_build])
    else
      head 422
    end
  end

  def rebuild
    project = Project.find_by! token: params[:id]

    if new_build = project.rebuild(params[:branch])
      respond_with(new_build, location: [:api, new_build])
    else
      head 422
    end
  end

  def branches
    branches = project.branches
    respond_to do |want|
      want.json { render json: branches }
    end
  end

  private

    def project
      @project ||= current_company.projects.find params[:id]
    end

end
