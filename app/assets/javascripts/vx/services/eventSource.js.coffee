Vx.service 'eventSource', [ '$rootScope'
  ($scope) ->

    $bus = $scope.$new()
    sub  = new EventSource("/api/events")

    sub.addEventListener "event", (e) ->
      data    = JSON.parse(e.data)
      channel = data.channel
      event   = data.event
      $bus.$broadcast(channel, data.payload)

    sub.onopen = (e) ->
      console.log "---> Open SSE connection to #{sub.url}"

    subscribe: (name, callback) ->
      $bus.$on name, (e, data) ->
        $scope.$apply ->
          callback(data)
]

