require 'active_support/notifications'
require 'vx/instrumentation'

$stdout.puts ' --> initializing ActiveSupport::Notifications for action_controller'

ActiveSupport::Notifications.subscribe(/\.action_controller$/) do |event, started, finished, _, payload|
  Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
end
