class Api::UsersController < Api::BaseController
  serialization_scope :current_company

  before_action :authorize_admin, only: [:index, :update, :destroy]
  before_action :authorize_to_destroy, only: :destroy

  respond_to :json

  def index
    @users = current_company.users.includes(
      :user_companies,
    )
    respond_with(@users, each_serializer: UserListSerializer)
  end

  def update
    @user = current_company.users.find(params[:id])

    if @user.update_with_company(current_company, user_params)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def me
    @user = current_user
    respond_with(@user, serializer: CurrentUserSerializer)
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
      params.require(:user).permit(:role, :name, :email)
    end
end
