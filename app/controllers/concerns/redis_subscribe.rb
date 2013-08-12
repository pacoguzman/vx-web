module RedisSubscribe

  def subscribe
    redis = Redis.new
    begin
      Rails.logger.info "subscribing to 'events.*'"
      redis.psubscribe("events.*") do |on|
        on.pmessage do |pattern, event, data|
          Rails.logger.debug "recieve #{event.inspect} #{data.inspect}"
          yield event, data
        end
      end
    rescue IOError
      Rails.logger.info "steram closed"
    ensure
      redis.close
    end
  end

end
