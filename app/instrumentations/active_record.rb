require 'active_support/notifications'
require 'vx/instrumentation'

$stdout.puts ' --> initializing ActiveSupport::Notifications for active_record'

ActiveSupport::Notifications.subscribe(/\.active_record$/) do |event, started, finished, _, payload|

  binds =
    (payload[:binds] || []).map do |column, value|
      if column
        if column.binary?
          value = "<#{value.bytesize} bytes of binary data>"
        end
        [column.name, value]
      else
        [nil, value]
      end
    end.inspect

  payload = {
    sql:      payload[:sql].compact,
    binds:    binds,
    name:     payload[:name],
    duration: payload[:duration]
  }

  Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
end
