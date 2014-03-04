require 'active_support/notifications'
require 'vx/instrumentation'

$stdout.puts ' --> initializing ActiveSupport::Notifications for faraday'

ActiveSupport::Notifications.subscribe(/\.faraday$/) do |event, started, finished, _, payload|

  render_http_header = ->(headers) {
    (headers || []).map do |key,value|
      if %{ PRIVATE-TOKEN Authorization }.include?(key)
        value = value.gsub(/./, "*")
      end
      "#{key}: #{value}"
    end.join("\n")
  }

  payload = {
    method:           payload[:method],
    url:              payload[:url].to_s,
    status:           payload[:status],
    response_headers: render_http_header.call(payload[:response_headers]),
    request_headers:  render_http_header.call(payload[:request_headers])
  }

  Vx::Instrumentation.delivery event, payload, event.split("."), started, finished
end
