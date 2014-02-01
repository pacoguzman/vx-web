require Rails.root.join("app/middlewares/handle_exception")

Rails.application.config.middleware.insert 0, Vx::Web::HandleException
