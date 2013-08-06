class User < ActiveRecord::Base

  include GithubUser

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  has_many :identities, class_name: "UserIdentity"

end
