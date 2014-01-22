class CachedFile < ActiveRecord::Base

  include PublicUrl::CachedFile

  belongs_to :project

  validates :project_id, :file, :content_type, :file_size, :file_name,
    presence: true

  validates :file_name, uniqueness: { scope: :project_id }

  after_create :publish_created
  after_update :publish

  mount_uploader :file, FileUploader

  private

    def publish_created
      publish :created
    end

end

# == Schema Information
#
# Table name: cached_files
#
#  id           :integer          not null, primary key
#  project_id   :integer          not null
#  file         :string(255)      not null
#  content_type :string(255)      not null
#  file_size    :integer          not null
#  file_name    :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#

