class ProjectSubscription < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

  validates :project_id, :user_id, presence: true

  scope :active, ->{ where(subscribe: true) }

  class << self

    def subscribe_by_email(email, project)
      user = User.select(:id).find_by(email: email)

      if user
        subscription = project.subscriptions.where(user_id: user.id).exists?
        unless subscription
          project.subscriptions.create(user: user)
        end
      end
    end

  end

end

