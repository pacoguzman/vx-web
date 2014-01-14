require 'vx/builder'

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
    @project ||= ::Project.where(token: params[:token]).lock(true).first
  end

  def build
    @build ||= project.create_build_from_github_payload(payload)
  end

  def task
    ::Vx::Builder::Task.new(
      project.name,
      project.clone_url,
      build.sha,
      deploy_key: project.deploy_key,
      branch: build.branch,
      pull_request_id: build.pull_request_id
    )
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
          build                  &&
          assign_source_to_build &&
          assign_commit_to_build &&
          create_jobs            &&
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
        if build.jobs.create matrix: config.matrix_keys, number: number, source: config.to_yaml
          publish_job_message task, config, number
        else
          break
        end
      end
      build.jobs.any?
    end

    def publish_job_message(task, source, number)
      script = ::Vx::Builder::Script.new(task, source)

      message = ::Vx::Message::PerformJob.new(
        id:              build.id,
        job_id:          number,
        name:            project.name,
        before_script:   script.to_before_script,
        script:          script.to_script,
        after_script:    script.to_after_script,
        matrix_keys:     source.to_matrix_s
      )
      ::JobsConsumer.publish message
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
