Vx.service 'eventSource', [ '$rootScope', "currentUserStore"
  ($scope, currentUserStore) ->

    $bus = $scope.$new()

    currentUserStore.get().then (u) ->

      sub  = new EventSource(u.sse_path)

      sub.addEventListener "event", (e) ->
        data  = JSON.parse(e.data)
        event = data.event_name
        $bus.$broadcast(event, data.payload)

      sub.onopen = (e) ->
        console.log "---> Open SSE connection to #{sub.url}"

    subscribe: (name, callback) ->
      $bus.$on name, (e, data) ->
        $scope.$apply ->
          callback(data)
]

