class Api::BaseController < ApplicationController

  before_filter :default_format_json

  def default_format_json

    sleep 0.5

    if(request.headers["HTTP_ACCEPT"].nil? &&
       params[:format].nil?)
      request.format = "json"
    end
  end

end
