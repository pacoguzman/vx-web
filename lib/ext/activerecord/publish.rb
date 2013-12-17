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

        SseEventConsumer.publish message

        true
      end

    end
  end
end


ActiveRecord::Base.send :include, Vx::Web::Publish
