require 'active_support/notifications'
require 'vx/instrumentation'

$stdout.puts ' --> initializing ActiveSupport::Notifications for action_view'

ActiveSupport::Notifications.subscribe(/\.action_view$/) do |event, started, finished, _, payload|
  if event[0] != "!"
    Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
  end
end
