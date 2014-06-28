class SockdNotifyConsumer

  include Vx::Consumer

  exchange 'vx.sockd', durable: false, auto_delete: false
  fanout

  content_type "application/json"
end
