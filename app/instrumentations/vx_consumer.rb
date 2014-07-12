require 'active_support/notifications'
require 'vx/instrumentation'

$stdout.puts ' --> activate instrumentations for vx-consumer'

ActiveSupport::Notifications.subscribe(/\.consumer\.vx/) do |event, started, finished, _, payload|
  ingnored_consumers = %w{
    SockdNotifyConsumer
    JobLogsConsumer
  }

  unless ingnored_consumers.include?(payload[:consumer])
    Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
  end
end
