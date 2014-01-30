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
      @project ||= Project.find_by(token: params[:_token])
    end

    def payload
      @payload ||= project.build_payload
    end

    def process?
      if project && payload
        yield
      else
        Rails.logger.warn "Fail to process payload"
      end
    end

end
