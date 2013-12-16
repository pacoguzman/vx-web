module BuildMessages

  def to_perform_build_message(travis)
    ::Vx::Message::PerformBuild.new(
      id:         id,
      name:       project.name,
      src:        project.clone_url,
      sha:        sha,
      deploy_key: project.deploy_key,
      travis:     travis,
      branch:     branch
    )
  end

  def delivery_to_notifier
    ::BuildNotifyConsumer.publish self.attributes
  end

  def delivery_to_fetcher
    ::FetchBuildConsumer.publish self.id
  end

  def delivery_perform_build_message(travis)
    ::BuildsConsumer.publish to_perform_build_message(travis)
  end

end
