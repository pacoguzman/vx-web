module Gitlab::User

  extend ActiveSupport::Concern

  module ClassMethods

    ENV_RE = /^GITLAB_URL[0-9]*$/

    def gitlab_hosts(env = ENV)
      @github_hosts ||=
        env.keys.select{ |i| i =~ ENV_RE }.map do |key|
          URI(env[key])
        end
    end

  end
end

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

