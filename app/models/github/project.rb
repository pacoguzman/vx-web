module Github::Project

  extend ActiveSupport::Concern

  included do
    scope :github, -> { where provider: :github }
  end

end

# == Schema Information
#
# Table name: projects
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  http_url     :string(255)      not null
#  clone_url    :string(255)      not null
#  description  :text
#  provider     :string(255)
#  deploy_key   :text             not null
#  token        :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  identity_id  :integer
#  user_repo_id :integer          not null
#

