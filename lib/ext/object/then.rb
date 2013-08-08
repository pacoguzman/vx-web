class Object

  def then
    if self
      yield self
    else
      self
    end
  end

end
