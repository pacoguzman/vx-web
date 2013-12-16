module Vx
  module Web
    module Publish

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

        message = {
          channel: channel,
          event:   event,
          payload: payload
        }

        Rails.logger.debug "publish payload #{payload.inspect}"
        WsPublishConsumer.publish message, content_type: "application/json"

        true
      end

    end
  end
end


ActiveRecord::Base.send :include, Vx::Web::Publish
