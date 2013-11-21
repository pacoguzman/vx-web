class User < ActiveRecord::Base

  include Github::User

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  has_many :identities, class_name: "::UserIdentity", dependent: :nullify
  has_many :project_subscriptions, class_name: "::ProjectSubscription", dependent: :destroy

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

