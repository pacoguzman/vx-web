module Github
  module BuildFetcher

    GithubCommit = Struct.new(:sha, :message, :author, :author_email)

    def github
      project.identity || identity_not_found
      project.identity.user.github
    end

    def create_perform_build_message_using_github
      commit = fetch_commit_from_github
      build.update! commit.to_h
      
    end

    def fetch_commit_from_github
      re = github.commit project.name, build.sha
      GithubCommit.new(re.sha,
                       re.commit.message,
                       re.commit.author.name,
                       re.commit.author.email)
    end

  end
end
