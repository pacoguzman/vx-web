module PublicUrl
  module Build
    def public_url
      "http://#{Rails.configuration.x.hostname}/builds/#{self.id}"
    end

    def cache_url_prefix
      "http://#{Rails.configuration.x.hostname}/f/cached_files/#{project.token}"
    end

    def artifacts_url_prefix
      "http://#{Rails.configuration.x.hostname}/f/artifacts/#{id}/#{token}"
    end
  end

  module Project
    def public_url
      "http://#{Rails.configuration.x.hostname}/projects/#{self.id}"
    end
  end

  module CachedFile
    def public_url
      "http://#{Rails.configuration.x.hostname}/f/cached_files/#{project.token}/#{file_name}"
    end
  end

  module Artifact
    def public_url
      "http://#{Rails.configuration.x.hostname}/f/artifacts/#{build.id}/#{build.token}/#{file_name}"
    end
  end
end
