module Vx
  module Instrumentation
    class Rails < Subscriber

      event(/\.(action_controller|action_view|action_mailer|active_support|railties)$/)

    end
  end
end
