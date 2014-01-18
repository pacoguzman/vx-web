module PublicUrl
  module Build
    def public_url
      "http://#{Rails.configuration.x.hostname}/builds/#{self.id}"
    end

    def cache_url_prefix
      "http://#{Rails.configuration.x.hostname}/cached_files/u/#{project.token}"
    end
  end

  module Project
    def public_url
      "http://#{Rails.configuration.x.hostname}/projects/#{self.id}"
    end
  end

  module CachedFile
    def public_url
      "http://#{Rails.configuration.x.hostname}/cached_files/u/#{project.token}/#{file_name}"
    end
  end
end
