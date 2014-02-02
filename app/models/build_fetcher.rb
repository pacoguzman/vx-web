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

  def source
    ::Vx::Builder::Source.new(build.source)
  end

  def matrix
    ::Vx::Builder::Source::Matrix.new(source).configurations
  end

  def perform
    transaction do
      guard do
        (
          build         &&
          build.save    &&
          create_jobs   &&
          publish_jobs  &&
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

    def create_jobs
      matrix.each_with_index do |config, idx|
        number = idx + 1
        build.jobs.create(
          matrix: config.matrix_keys,
          number: number,
          source: config.to_yaml
        ) || return
      end
      build.jobs.any?
    end

    def publish_jobs
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

    def with_sc
      conn = project && project.sc
      if conn && block_given?
        yield conn
      end
    end

    def sc_model
      @sc_model ||= project && project.sc_model
    end

end
