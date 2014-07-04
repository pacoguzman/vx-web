class Users::ProjectSubscriptionsController < ApplicationController
  skip_before_filter :authorize_user, except: [:show]

  layout "session"

  def unsubscribe
    @project      = Project.find params[:project_id]
    @subscription = @project.subscriptions.find params[:id]
    @subscription.update(subscribe: false)
  end

end
