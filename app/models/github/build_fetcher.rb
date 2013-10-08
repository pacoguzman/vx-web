require 'base64'

module Github
  module BuildFetcher

    GithubCommit = Struct.new(:sha, :message, :author, :author_email, :http_url)

    def github
      project.identity || identity_not_found
      project.identity.user.github
    end

    def create_perform_build_message_using_github
      commit = fetch_commit_from_github
      build.update! commit.to_h

      travis = fetch_travis_from_github
      build.delivery_perform_build_message(travis)
    end

    def fetch_travis_from_github
      travis = github.contents project.name, ref: build.sha, path: ".travis.yml"
      Base64.decode64 travis.content
    end

    def fetch_commit_from_github
      re = github.commit project.name, build.sha
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
