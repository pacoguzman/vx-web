Vx.service 'eventSource', [ '$rootScope'
  ($scope) ->

    $bus      = $scope.$new()
    pusher    = null
    pusherKey = document.getElementsByTagName("body")[0].dataset.pusherKey

    if window.Pusher && pusherKey
      pusher = new Pusher(pusherKey);

    sub = new EventSource("/sse")

    sub.addEventListener "sse", (e) ->
      data    = JSON.parse(e.data)
      channel = data.channel
      event   = data.event
      $bus.$broadcast(channel, data.payload)

    subscribe: (name, callback) ->
      $bus.$on name, (e, data) ->
        $scope.$apply ->
          callback(data)
]

