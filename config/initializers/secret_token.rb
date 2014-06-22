if %w{ development test }.include?(Rails.env)
  VxWeb::Application.config.secret_key_base = 'secret'
else
  VxWeb::Application.config.secret_key_base = ENV['VX_WEB_SECRET']
end

