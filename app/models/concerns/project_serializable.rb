module ProjectSerializable

  def as_json(*args)
    {
      id:          id,
      name:        name,
      description: description,
      http_url:    http_url
    }
  end

end
