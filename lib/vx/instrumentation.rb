require 'thread'

ActiveSupport::Notifications.subscribe(/.*/) do |name, started, finished, uid, payload|
  skip  = false

  render_bind = ->(column, value) {
    if column
      if column.binary?
        value = "<#{value.bytesize} bytes of binary data>"
      end
      [column.name, value]
    else
      [nil, value]
    end
  }

  render_http_header = ->(headers) {
    headers.map do |key,value|
      if %{ PRIVATE-TOKEN Authorization }.include?(key)
        value = value.gsub(/./, "*")
      end
      "#{key}: #{value}"
    end.join("\n")
  }

  case name

  # Rails
  when /^\!/
    skip = true

  when "sql.active_record"
    payload = {
      sql:      payload[:sql].compact,
      binds:    (payload[:binds] || []).map{|k,v| render_bind.call(k,v) }.inspect,
      name:     payload[:name],
      duration: payload[:duration]
    }

  when "request.action_dispatch"
    req     = payload.delete(:request)
    payload = {
      path:   req.fullpath,
      ip:     req.ip,
      method: req.method,
    }

  when 'request.faraday'
    name = 'request.http'
    payload = {
      method:           payload[:method],
      url:              payload[:url].to_s,
      status:           payload[:status],
      response_headers: render_http_header.call(payload[:response_headers]),
      request_headers:  render_http_header.call(payload[:request_headers])
    }
  end

  unless skip
    tm = started.strftime('%Y-%m-%dT%H:%M:%S.%N%z')
    Vx::Common::Logger.logger.log(
      ::Logger::INFO,
      "@event"      => name,
      "@process_id" => Process.pid,
      "@thread_id"  => Thread.current.object_id,
      "@timestamp"  => tm,
      "@duration"   => (finished - started).to_f,
      "@fields"     => payload,
      "@tags"       => name.split(".")
    )
  end
end
