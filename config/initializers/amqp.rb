require 'vx/common/amqp'

Vx::Common::AMQP.configure do |c|

  logger = Rails.logger

  c.before_subscribe do |e|
    logger.warn "[#{e[:name]}] subsribing #{e[:exchange].name}"
  end

  c.after_subscribe do |e|
    logger.warn "[#{e[:name]}] shutdown"
  end

  c.before_recieve do |e|
    unless e[:payload].class.to_s == "Vx::Message::JobLog"
      logger.warn "[#{e[:name]}] payload recieved #{e[:payload]}"
    end
  end

  c.after_recieve do |e|
    unless e[:payload].class.to_s == "Vx::Message::JobLog"
      logger.warn "[#{e[:name]}] commit message"
    end
  end

  c.before_publish do |e|
    logger.warn "publish #{e[:message].inspect}"
  end

  c.on_error do |e|
    ::Airbrake.notify(e)
  end

  c.content_type = 'application/x-protobuf'
  c.logger       = nil
end
