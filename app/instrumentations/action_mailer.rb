require 'active_support/notifications'
require 'vx/instrumentation'

$stdout.puts ' --> initializing ActiveSupport::Notifications for action_mailer'

ActiveSupport::Notifications.subscribe(/\.action_mailer$/) do |event, started, finished, _, payload|
  Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
end
