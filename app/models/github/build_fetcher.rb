require 'base64'

module Github
  module BuildFetcher

    GithubCommit = Struct.new(:sha, :message, :author, :author_email, :http_url)

    def github
      if project && project.identity
        project.identity.user.github
      end
    end

    def create_perform_build_message_using_github
      if github
        commit = fetch_commit_from_github
        if commit && build.update(commit.to_h)
          if travis = fetch_travis_from_github
            build.delivery_perform_build_message(travis)
          end
        end
      end
    end

    def fetch_travis_from_github
      begin
        travis = github.contents project.name, ref: build.sha, path: ".travis.yml"
        Base64.decode64 travis.content
      rescue ::Octokit::NotFound => e
        Rails.logger.error "ERROR: #{e.inspect}"
        nil
      end
    end

    def fetch_commit_from_github
      re = nil
      begin
        re = github.commit project.name, build.sha
      rescue ::Octokit::NotFound => e
        Rails.logger.error "ERROR: #{e.inspect}"
      end

      if re
        url = re.rels[:html]
        GithubCommit.new(
          re.sha,
          re.commit.message,
          re.commit.author.name,
          re.commit.author.email,
          url && url.href
        )
      end
    end

  end
end
