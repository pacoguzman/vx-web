class CachedFile < ActiveRecord::Base
  belongs_to :project

  mount_uploader :file, FileUploader
end
