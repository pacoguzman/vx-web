class Api::ArtifactsController < ApplicationController

  before_filter :find_build, only: [:index]
  before_filter :find_build_by_token, only: [:upload, :download]
  before_filter :find_artifact_by_file_name, only: [:upload, :download]

  skip_before_filter :authorize_user, only: [:upload, :download]
  skip_before_filter :verify_authenticity_token, only: [:upload]

  respond_to :json

  def index
    @artifacts = @build.artifacts
    respond_with(@artifacts)
  end

  def destroy
    @artifact = Artifact.find params[:id]
    @artifact.destroy
    respond_with(@artifact)
  end

  def upload
    @artifact.file = file_input

    if @artifact.save
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def download
    if @artifact.persisted?
      send_file @artifact.file.path, type: @artifact.content_type
    else
      head :not_found
    end
  end

  private

    def find_build
      @build = Build.find params[:build_id]
    end

    def find_build_by_token
      @build = Build.find_by! token: params[:token], id: params[:build_id]
    end

    def find_artifact_by_file_name
      @artifact = @build.artifacts.find_by file_name: file_name
      @artifact ||= @build.artifacts.build file_name: file_name
    end

    def file_name
      @file_name ||= begin
        ext = params[:file_ext]
        params[:file_name] + ".#{ext}"
      end
    end

    def file_input
      @file_input ||= begin
        input = request.body.dup
        input.original_filename = file_name
        input
      end
    end

end
