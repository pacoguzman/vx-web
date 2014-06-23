require 'digest/md5'

module GavatarHelper

  def gavatar_url(email, options = {})
    if email
      m = Digest::MD5.hexdigest(email)
      m = "//www.gravatar.com/avatar/#{m}"
      if options[:size]
        m = "#{m}?s=#{options[:size]}"
      end
      m
    end
  end

end
