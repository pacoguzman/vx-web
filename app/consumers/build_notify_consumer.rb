class BuildNotifyConsumer

  include Vx::Consumer

  exchange 'vx.web.builds.notify'
  queue    'vx.web.builds.notify'
  ack

  model Hash
  content_type 'application/json'

  def perform(message)
    build_id = message["id"]
    status   = message["status"]

    if build_id && status
      ::BuildNotifier.new(message).notify
    end
    ack
  end

end
