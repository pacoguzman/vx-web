require 'carrierwave/processing/mime_types'

class FileUploader < CarrierWave::Uploader::Base

  include CarrierWave::MimeTypes

  storage :file

  process :set_content_type
  process :save_content_type_and_size_in_model

  def store_dir
    "#{Rails.root}/private/#{Rails.env}/#{model.class.to_s.underscore}/#{mounted_as}/#{splitted_model_id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{mounted_as}"
  end

  def splitted_model_id
    ("%09d" % model.id).scan(/.{3}/).join("/")
  end

  # By default, CarrierWave copies an uploaded file twice, first copying the
  # file into the cache, then copying the file into the store. For large files,
  # this can be prohibitively time consuming.
  #
  # You may change this behavior by overriding either or both of the
  # move_to_cache and move_to_store methods:
  def move_to_cache
    true
  end

  def move_to_store
    true
  end

  private

    def save_content_type_and_size_in_model
      model.content_type = file.content_type if file.content_type
      model.file_size    = file.size
    end

end
