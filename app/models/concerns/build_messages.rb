module BuildMessages

  def to_perform_build_message
    Evrone::CI::Message::PerformBuild.new(
      id:         id,
      name:       project.name,
      src:        project.clone_url,
      sha:        sha,
      deploy_key: project.deploy_key,
    )
  end

  def publish_perform_build_message
    BuildsConsumer.publish to_perform_build_message
  end

end
