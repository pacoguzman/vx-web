if VX_COMPONENT_NAME == 'http'
  $stdout.puts ' --> boot ServerSideEventsConsumer'
  ServerSideEventsConsumer.subscribe
end

