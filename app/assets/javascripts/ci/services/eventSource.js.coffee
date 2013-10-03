CI.service 'eventSource', [ '$rootScope'
  ($scope) ->

    #Pusher.log = (message) ->
    #  if window.console && window.console.log
    #    window.console.log(message)

    pusherKey = document.getElementsByTagName("body")[0].dataset.pusherKey
    pusher = new Pusher(pusherKey);

    subscribe: (name, callback) ->
      proxy = (e) ->
        $scope.$apply ->
          callback(angular.fromJson e)

      channel = pusher.subscribe(name)
      channel.bind "created",   proxy
      channel.bind "updated",   proxy
      channel.bind "destroyed", proxy
]

