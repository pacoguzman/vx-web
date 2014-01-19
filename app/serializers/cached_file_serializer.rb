class CachedFileSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :id, :project_id, :name, :size_in_bytes, :size, :download_url,
    :updated_at

  def name
    object.file_name
  end

  def size_in_bytes
    object.file_size
  end

  def size
    number_to_human_size(object.file_size)
  end

  def download_url
    object.public_url
  end

end
