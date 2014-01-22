module Github

  module BuildNotifier

    def github
      build.project.identity || identity_not_found
      build.project.identity.user.github
    end

    def create_github_commit_status
      if github && github_commit_status
        begin
          github.create_status(
            build.project.name,
            build.sha,
            github_commit_status,
            description: description,
            target_url:  build.public_url
          )
        rescue Octokit::UnprocessableEntity => e
          Rails.logger.error "ERROR: #{e.inspect}"
        end
      end
    end

    def github_commit_status
      case build.status_name
      when :started
        'pending'
      when :passed
        'success'
      when :failed
        'failure'
      when :errored
        'error'
      end
    end

  end
end
