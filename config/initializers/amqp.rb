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
    logger.warn "[#{e[:name]}] payload recieved #{e[:payload].inspect[0..60]}..."
  end

  c.after_recieve do |e|
    logger.warn "[#{e[:name]}] commit message"
  end

  c.before_publish do |e|
    logger.warn "message delivered #{e[:message].inspect[0...60]}..."
  end

  c.on_error do |e|
    ::Airbrake.notify(e)
  end

  c.content_type = 'application/x-protobuf'
  c.logger       = nil
end
