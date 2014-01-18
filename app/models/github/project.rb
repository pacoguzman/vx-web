module Github::Project

  extend ActiveSupport::Concern

  included do
    scope :github, -> { where provider: :github }
  end

  def new_build_from_github_payload(payload)
    attrs = {
      pull_request_id:  payload.pull_request_number,
      branch:           payload.branch,
      branch_label:     payload.branch_label,
      sha:              payload.head,
      http_url:         payload.url,
    }

    builds.build(attrs)
  end

end

# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  http_url    :string(255)      not null
#  clone_url   :string(255)      not null
#  description :text
#  provider    :string(255)
#  deploy_key  :text             not null
#  token       :string(255)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  identity_id :integer
#

