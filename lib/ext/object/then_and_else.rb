class Object
  def then &block
    if self
      instance_eval(&block)
    else
      self
    end
  end

  def or_else &block
    if !self
      instance_eval(&block)
    else
      self
    end
  end
end
