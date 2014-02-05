require 'active_support/notifications'
require 'vx/instrumentation'

$stdout.puts ' --> initializing ActiveSupport::Notifications for vx-consumer'

ActiveSupport::Notifications.subscribe(/\.consumer\.vx/) do |event, started, finished, _, payload|
  Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
end

ActiveSupport::Notifications.subscribe(/\.consumer\.web\.vx/) do |event, started, finished, _, payload|
  Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
end
