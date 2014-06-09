class Api::UsersController < Api::BaseController
  before_filter :authorize_admin, only: [:index, :update]

  respond_to :json

  def index
    @users = current_company.users
    render json: @users.map { |user| UserSerializer.new(user, company: current_company) }
  end

  def update
    @user = current_company.users.find(params[:id])

    if @user.update_role(user_params[:role], current_company)
      render json: UserSerializer.new(@user, company: current_company)
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  def me
    @user = current_user
    render json: UserSerializer.new(@user, company: current_company)
  end

private

  def user_params
    params.require(:user).permit(:role)
  end
end
