class BuildsController < ApplicationController
  def sha
    build = ::Build.find_by!(sha: params[:sha])
    redirect_to "/builds/#{build.id}"
  end
end
