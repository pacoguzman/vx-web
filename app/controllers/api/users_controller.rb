class Api::UsersController < Api::BaseController
  serialization_scope :current_company

  before_action :authorize_admin, only: [:index, :update, :destroy]
  before_action :authorize_to_destroy, only: :destroy

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

  def destroy
    user.delete_from_company(current_company)
    head :ok
  end

  private

    def authorize_to_destroy
      if current_user == user
        render nothing: true, status: :method_not_allowed
        false
      else
        true
      end
    end

    def user
      @user ||= User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role)
    end
end
