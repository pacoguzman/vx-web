module Vx
  module Instrumentation
    class ActiveRecord < Subscriber

      event(/\.active_record$/)

      def process
        self.payload = {
          sql:      payload[:sql].compact,
          binds:    render_binds,
          name:     payload[:name],
          duration: payload[:duration]
        }
      end

      private

        def render_binds
          (payload[:binds] || []).map do |column, value|
            if column
              if column.binary?
                value = "<#{value.bytesize} bytes of binary data>"
              end
              [column.name, value]
            else
              [nil, value]
            end
          end.inspect
        end

    end
  end
end
