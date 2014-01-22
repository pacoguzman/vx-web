class RepoCallbacksController < ApplicationController

  skip_before_filter :authorize_user
  skip_before_filter :verify_authenticity_token

  def create
    process? do
      PayloadConsumer.publish payload.to_hash.merge(project_id: project.id)
    end
    head :ok
  end

  private
    def project
      @project ||= Project.select(:id).find_by(token: params[:token])
    end

    def payload
      @payload ||= Vx::ServiceConnector.payload(:github, params)
    end

    def process?
      if project && !payload.ignore?
        yield
      else
        Rails.logger.warn "ignore payload: #{payload.inspect}"
      end
    end

end
