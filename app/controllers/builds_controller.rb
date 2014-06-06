class BuildsController < ApplicationController
  def sha
    build = ::Build.find_by!(sha: params[:sha])
    redirect_to "/ui/builds/#{build.id}"
  end
end
