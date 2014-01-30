require 'thread'

ActiveSupport::Notifications.subscribe(/.*/) do |name, started, finished, uid, payload|
  level = Logger::INFO
  skip  = false

  case name

  # Rails
  when /^\!/
    skip = true

  when "request.action_dispatch"
    req     = payload.delete(:request)
    payload = {
      path:   req.fullpath,
      ip:     req.ip,
      method: req.method,
      uuid:   req.uuid
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
