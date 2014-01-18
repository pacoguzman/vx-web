class BuildFetcher

  include Github::BuildFetcher

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def payload
    @payload ||= ::Github::Payload.new params
  end

  def project
    @project ||= ::Project.lock(true).find_by(token: params["token"])
  end

  def build
    @build ||= project.create_build_from_github_payload(payload)
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
        Rails.logger.info "subscribe #{email} to #{project}"
        ProjectSubscription.subscribe_by_email(email, project)
      end
      true
    end

    def create_jobs
      matrix.each_with_index do |config, idx|
        number = idx + 1
        Rails.logger.info "create job: number:#{number}, matrix: #{config.matrix_keys.inspect}"
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
      fetch_commit_from_github.try do |commit|
        Rails.logger.info "assign commit: #{commit.inspect}"
        build.update commit.to_h
      end
    end

    def assign_source_to_build
      fetch_configuration_from_github.try do |source|
        Rails.logger.info "assign source"
        build.update source: source
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

end
