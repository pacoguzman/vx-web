module PublicUrl
  module Build
    def public_url
      "#{Rails.configuration.x.hostname}/ui/builds/#{self.id}"
    end

    def cache_url_prefix
      "#{Rails.configuration.x.hostname}/f/cached_files/#{project.token}"
    end
  end

  module Project
    def public_url
      "#{Rails.configuration.x.hostname}/ui/projects/#{self.id}"
    end
  end

  module CachedFile
    def public_url
      "#{Rails.configuration.x.hostname}/f/cached_files/#{project.token}/#{file_name}"
    end
  end
end
