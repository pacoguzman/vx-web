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
          build                    &&
          assign_source_to_build   &&
          assign_commit_to_build   &&
          build.save               &&
          create_jobs              &&
          publish_jobs             &&
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
        Rails.logger.warn "subscribe #{email} to #{project}"
        ProjectSubscription.subscribe_by_email(email, project)
      end
      true
    end

    def create_jobs
      matrix.each_with_index do |config, idx|
        number = idx + 1
        Rails.logger.warn "create job: number:#{number}, matrix: #{config.matrix_keys.inspect}"
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

    def assign_commit_to_build
      with_connector do |conn|
        commit = conn.commits(connector_model).get(build.sha)
        if commit
          Rails.logger.warn "assign commit: #{commit.inspect}"
          build.sha          = commit.sha
          build.message      = commit.message
          build.author       = commit.author
          build.author_email = commit.author_email
          build.http_url     = commit.http_url
          true
        end
      end
    end

    def assign_source_to_build
      with_connector do |conn|
        file = conn.files(connector_model).get(build.sha, '.travis.yml')
        if file
          Rails.logger.warn "assign source: #{file.inspect}"
          build.source = file
          true
        end
      end
    end

    def guard
      if project && !payload.ignore?
        yield
      end
    end

    def transaction
      Build.transaction { yield }
    end

    def with_connector
      conn = project && project.service_connector
      if conn && block_given?
        yield conn
      end
    end

    def connector_model
      @connector_model ||= project && project.to_service_connector_model
    end

end
