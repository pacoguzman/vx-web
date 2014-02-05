class String
  def to_safe_utf8
    safe = force_encoding("UTF-8")
    unless safe.valid_encoding?
      safe = safe.force_encoding("BINARY").encode("UTF-8", invalid: :replace, undef: :replace)
    end
    safe
  end
end
