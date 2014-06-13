class Api::UsersController < Api::BaseController
  serialization_scope :current_company

  before_filter :authorize_admin, only: [:index, :update]

  respond_to :json

  def index
    @users = current_company.users.includes(
      :identities,
      :companies,
      :active_project_subscriptions
    )
    respond_with(@users)
  end

  def update
    @user = current_company.users.find(params[:id])

    if @user.update_role(user_params[:role], current_company)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def me
    @user = current_user
    respond_with(@user)
  end

private

  def user_params
    params.require(:user).permit(:role)
  end
end
