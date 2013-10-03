module Evrone
  module CI
    module Web
      module RedisPublish

        def publish(*args)

          options = args.extract_options!
          event   = args.first || :updated

          serializer = options[:serializer]
          serializer ||= begin
            self.class.to_s.underscore
          end

          serializer_class = "#{serializer.to_s.camelize}Serializer".constantize
          data = serializer_class.new(self).as_json
          channel = self.class.table_name

          payload = {
            id:     id,
            name:   channel,
            event:  event,
            data:   data
          }

          Rails.logger.debug "publish payload #{payload.inspect}"

          Pusher[channel].trigger event, payload
        end

      end
    end
  end
end


ActiveRecord::Base.send :include, Evrone::CI::Web::RedisPublish
