class Api::UserIdentities::GitlabController < Api::BaseController

  respond_to :json

  def update
    @identity = current_user.identities.find(params[:id])
    @session  = Gitlab::UserSession.new(identity_params)
    if @session.update_identity(@identity)
      head 204
    else
      head 422
    end
  end

  def create
    @session  = Gitlab::UserSession.new(identity_params)
    @identity = @session.create_identity(current_user)
    if @identity
      respond_with(@identity)
    else
      head 422
    end
  end

  private

    def identity_params
      params.require(:user_identity).permit(:login, :password, :url)
    end
end
