class Api::UsersController < Api::BaseController

  respond_to :json

  def me
    respond_with(@user = current_user)
  end
end
