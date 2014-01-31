module Vx
  module Instrumentation
    class ActionDispatch < Subscriber

      event(/\.action_dispatch$/)

      def process
        req     = payload.delete(:request)
        self.payload = {
          path:   req.fullpath,
          ip:     req.ip,
          method: req.method,
        }
      end

    end
  end
end
