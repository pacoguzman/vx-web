class CloudNotifyConsumer

  include Vx::Consumer

  exchange 'vx.auto_scale.notify'
  content_type 'application/json'

end

