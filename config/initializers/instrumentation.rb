require Rails.root.join("app/middlewares/handle_exception_middleware")

Rails.application.config.middleware.insert 0, Vx::Web::HandleExceptionMiddleware

Vx::Instrumentation.install "#{Rails.root}/log/vxweb-#{VX_COMPONENT_NAME}.#{Rails.env}.log.json"

Dir[Rails.root.join("app/instrumentations/*.rb")].each do |f|
  require f
end

