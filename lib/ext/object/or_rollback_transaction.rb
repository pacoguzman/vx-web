class Object

  def or_rollback_transaction
    if self
      self
    else
      raise ::ActiveRecord::Rollback
    end
  end

end
