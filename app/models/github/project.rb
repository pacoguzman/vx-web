module Github::Project
  extend ActiveSupport::Concern

  included do
    scope :github, -> { where provider: :github }
  end

end
