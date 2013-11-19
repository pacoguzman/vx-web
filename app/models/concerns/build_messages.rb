module BuildMessages

  def to_perform_build_message(travis)
    ::Evrone::CI::Message::PerformBuild.new(
      id:         id,
      name:       project.name,
      src:        project.clone_url,
      sha:        sha,
      deploy_key: project.deploy_key,
      travis:     travis,
      branch:     branch
    )
  end

  def delivery_to_notifier(state)
    ::BuildNotifyConsumer.publish build_id: self.id, status: state
  end

  def delivery_to_fetcher
    ::FetchBuildConsumer.publish self.id
  end

  def delivery_perform_build_message(travis)
    ::BuildsConsumer.publish to_perform_build_message(travis)
  end

end
