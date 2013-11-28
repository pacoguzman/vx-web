CI.service 'eventSource', [ '$rootScope'
  ($scope) ->

    pusherKey = document.getElementsByTagName("body")[0].dataset.pusherKey
    if window.Pusher
      pusher = new Pusher(pusherKey);

    subscribe: (name, callback) ->
      proxy = (e) ->
        $scope.$apply ->
          callback(angular.fromJson e)

      if pusher
        channel = pusher.subscribe(name)
        channel.bind "created",   proxy
        channel.bind "updated",   proxy
        channel.bind "destroyed", proxy
]

