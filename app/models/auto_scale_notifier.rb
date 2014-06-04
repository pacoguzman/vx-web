class AutoScaleNotifier

  def self.notify
    s = Job.status
    n =  (s[:initialized] || 0) + (s[:started] || 0)
    if n > 0
      m = {
        key:  key,
        jobs: n
      }
      AutoScaleConsumer.publish m
    end
  end

  def self.key
    @key ||= "rx.#{Rails.env}"
  end
end
