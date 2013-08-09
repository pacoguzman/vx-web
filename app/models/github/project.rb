module Github::Project

  extend ActiveSupport::Concern

  included do
    scope :github, -> { where provider: :github }
  end

  def create_build_from_github_request
  end

end
