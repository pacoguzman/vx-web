class Artifact < ActiveRecord::Base
  belongs_to :build

  validates :build_id, :file, :content_type, :file_size, :file_name, presence: true

  mount_uploader :file, FileUploader
end

# == Schema Information
#
# Table name: artifacts
#
#  id           :integer          not null, primary key
#  build_id     :integer          not null
#  file         :string(255)      not null
#  content_type :string(255)      not null
#  file_size    :string(255)      not null
#  file_name    :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#

