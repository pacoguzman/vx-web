Vx.service 'eventSource', [ '$rootScope'
  ($scope) ->

    $bus = $scope.$new()
    sub  = new EventSource("/sse_events")

    sub.addEventListener "sse_event", (e) ->
      data    = JSON.parse(e.data)
      channel = data.channel
      event   = data.event
      $bus.$broadcast(channel, data.payload)

    sub.onopen = (e) ->
      console.log "---> Open sse connection to #{sub.url}"

    subscribe: (name, callback) ->
      $bus.$on name, (e, data) ->
        $scope.$apply ->
          callback(data)
]

