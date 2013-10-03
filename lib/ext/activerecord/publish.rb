module Evrone
  module CI
    module Web
      module RedisPublish

        def publish(*args)

          options = args.extract_options!
          action  = args.first || :updated

          serializer = options[:serializer]
          serializer ||= begin
            self.class.to_s.underscore
          end

          serializer_class = "#{serializer.to_s.camelize}Serializer".constantize
          data = serializer_class.new(self).as_json

          payload = {
            id:     id,
            name:   self.class.table_name,
            action: action,
            data:   data
          }

          Rails.logger.debug "publish payload #{payload.inspect}"
          Rails.redis.publish "events.#{self.class.table_name}", payload.to_json

        end

      end
    end
  end
end


ActiveRecord::Base.send :include, Evrone::CI::Web::RedisPublish
