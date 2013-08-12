CI.service 'eventSource', [ '$rootScope'
  ($scope) ->

    eventSource = new EventSource('/events')

    subscribe: (name, callback) ->
      proxy = (e) ->
        $scope.$apply ->
          callback(angular.fromJson e.data)
      eventSource.addEventListener name, proxy, false
]

