module Rails
  def self.redis
    @redis ||= ::Redis.new
  end
end
