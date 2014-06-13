class BuildsController < ApplicationController
  def sha
    build = ::Build.find_by!(sha: params[:sha])
    redirect_to build.public_url
  end
end
