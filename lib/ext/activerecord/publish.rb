module Evrone
  module CI
    module Web
      module RedisPublish

        def publish(action = nil)

          action ||= :updated
          payload = {
            id:     id,
            name:   self.class.table_name,
            action: action,
            data:   as_json
          }

          Rails.logger.debug "publish payload #{payload.inspect}"
          Rails.redis.publish "events.#{self.class.table_name}", payload.to_json

        end

      end
    end
  end
end


ActiveRecord::Base.send :include, Evrone::CI::Web::RedisPublish
