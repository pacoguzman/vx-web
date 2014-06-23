Rails.application.config.middleware.insert 0, Vx::Instrumentation::Rack::HandleExceptionsMiddleware

Vx::Instrumentation.install "#{Rails.root}/log/vxweb-#{VX_COMPONENT_NAME}.#{Rails.env}.log.json"

Vx::Instrumentation.activate :action_controller, :action_dispatch, :action_mailer,
  :action_view, :active_record, :active_support, :faraday

Dir[Rails.root.join("app/instrumentations/*.rb")].each do |f|
  require f
end
