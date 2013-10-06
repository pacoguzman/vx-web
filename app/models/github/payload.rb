class Github::Payload

  def initialize(params)
    @params = params || {}
  end

  def pull_request?
    key? "pull_request"
  end

  def pull_request_number
    if pull_request? && key?("number")
      self["number"]
    end
  end

  def head
    if pull_request?
      pull_request["head"]["sha"]
    else
      self["after"]
    end
  end

  def base
    if pull_request?
      pull_request["base"]["sha"]
    else
      self["before"]
    end
  end

  def branch
    if pull_request?
      pull_request["head"]["ref"]
    else
      self["ref"].split("refs/heads/").last
    end
  end

  def branch_label
    if pull_request?
      pull_request["head"]["label"]
    else
      branch
    end
  end

  def url
    if pull_request?
      pull_request["url"]
    else
      self["compare"]
    end
  end

  private

    def pull_request
      self["pull_request"]
    end

    def key?(name)
      @params.key? name
    end

    def [](val)
      @params[val]
    end

end
