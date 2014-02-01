require Rails.root.join("app/middlewares/handle_exception")
Rails.application.config.middleware.insert 0, Vx::Web::HandleException

VX_COMPONENT_NAME ||= ENV['VX_COMPONENT_NAME'] || "web"

Vx::Instrumentation.install "#{Rails.root}/log/#{VX_COMPONENT_NAME}.#{Rails.env}.json"

