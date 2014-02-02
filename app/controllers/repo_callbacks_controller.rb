class RepoCallbacksController < ApplicationController

  skip_before_filter :authorize_user
  skip_before_filter :verify_authenticity_token

  def create
    process? do
      PayloadConsumer.publish(
        payload.to_hash.merge(
          project_id:   project.id,
          project_name: project.name
        ),
        project_id: project.id
      )
    end
    head :ok
  end

  private

    def project
      @project ||= Project.find_by(token: params[:_token])
    end

    def payload
      @payload ||= project.build_payload params
    end

    def process?
      if project && payload && !payload.ignore?
        yield
      else
        Rails.logger.warn "Cannot process payload"
      end
    end

end
