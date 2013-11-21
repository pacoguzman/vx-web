module PublicUrl
  module Build
    def public_url
      "http://#{Rails.configuration.x.hostname}/builds/#{self.id}"
    end
  end

  module Project
    def public_url
      "http://#{Rails.configuration.x.hostname}/projects/#{self.id}"
    end
  end
end
