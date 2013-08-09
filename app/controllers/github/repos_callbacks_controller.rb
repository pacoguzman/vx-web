class Github::ReposCallbacksController < Api::BaseController

  before_filter :find_project

  skip_before_filter :authorize_user
  skip_before_filter :intercept_html_requests

  def create
  end

end
