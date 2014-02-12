class Api::StatusController < Api::BaseController

  skip_before_filter :authorize_user, only: [:show]

  def show
    @status =
      case params[:id]
      when "jobs"
        Job.status
      else
        {}
      end
    render json: @status.to_json
  end
end
