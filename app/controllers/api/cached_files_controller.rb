class Api::CachedFilesController < ApplicationController

  before_filter :find_project, only: [:index]
  before_filter :find_project_by_token, only: [:upload, :download]
  before_filter :find_cached_file_by_file_name, only: [:upload, :download]

  skip_before_filter :authorize_user, only: [:upload, :download]
  skip_before_filter :verify_authenticity_token, only: [:upload]

  respond_to :json

  def index
    @cached_files = @project.cached_files
    respond_with(@cached_files)
  end

  def destroy
    @cached_file = CachedFile.find params[:id]
    @cached_file.destroy
    respond_with(@cached_file)
  end

  def upload
    @cached_file.file = file_input

    if @cached_file.save
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def download
    if @cached_file.persisted?
      send_file @cached_file.file.path, type: @cached_file.content_type
    else
      head :not_found
    end
  end

  private

    def find_project
      @project = Project.find params[:project_id]
    end

    def find_project_by_token
      @project = Project.find_by! token: params[:token]
    end

    def find_cached_file_by_file_name
      @cached_file = @project.cached_files.find_by file_name: file_name
      @cached_file ||= @project.cached_files.build file_name: file_name
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
