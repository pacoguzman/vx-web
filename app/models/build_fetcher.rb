class BuildFetcher

  attr_reader :payload, :project_id

  def initialize(params)
    @payload    = Vx::ServiceConnector::Model::Payload.from_hash(params)
    @project_id = params["project_id"].to_i
  end

  def project
    @project ||= ::Project.lock(true).find_by(id: project_id)
  end

  def build
    @build ||= project.new_build_from_payload(payload)
  end

  def perform
    transaction do
      guard do
        (
          build                         &&
          build.save                    &&
          build.create_jobs_from_matrix &&
          publish_perform_job_messages  &&
          subscribe_author_to_repo
        ).or_rollback_transaction
        build
      end
    end
  end

  private

    def subscribe_author_to_repo
      email = build.author_email
      if email
        ProjectSubscription.subscribe_by_email(email, project)
      end
      true
    end

    def publish_perform_job_messages
      build.jobs.each(&:publish_perform_job_message)
      true
    end

    def guard
      if project && !payload.ignore?
        yield
      end
    end

    def transaction
      Build.transaction { yield }
    end

end
