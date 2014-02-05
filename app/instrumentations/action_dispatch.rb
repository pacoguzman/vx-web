require 'active_support/notifications'
require 'vx/instrumentation'

$stdout.puts ' --> initializing ActiveSupport::Notifications for action_dispatch'

ActiveSupport::Notifications.subscribe(/\.action_dispatch$/) do |event, started, finished, _, payload|
  req = payload.delete(:request)
  payload = {
    path:           req.fullpath,
    ip:             req.remote_ip,
    method:         req.method,
    referer:        req.referer,
    content_length: req.content_length,
    user_agent:     req.user_agent
  }
  Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
end
