require 'thread'

ActiveSupport::Notifications.subscribe(/.*/) do |name, started, finished, uid, payload|
  level = Logger::INFO
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
      uuid:   req.uuid,
    }
  end

  unless skip
    tm = started.strftime('%Y-%m-%dT%H:%M:%S.%N%z')
    Vx::Common::Logger.logger.log(
      level,
      "@event"      => name,
      "@process_id" => Process.pid,
      "@thread_id"  => Thread.current.object_id,
      "@timestamp"  => tm,
      "@duration"   => (finished - started).to_f,
      payload:     payload
    )
  end
end
