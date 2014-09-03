Vx.service 'eventSource', [ '$rootScope', "currentUserModel", '$window'
  ($scope, currentUser, $window) ->

    $bus = $scope.$new()

    if $window.SockJS

      currentUser.get().then (me) ->

        url  = me.stream
        sock = new $window.SockJS(url)

        if sock
          sock.onopen = () ->
            console.log(" --> Open SockJS connection to #{url}");
            sock.send("subscribe: company/#{me.current_company}")

          sock.onclose = () ->
            console.log(" --> Closed SockJS connection")

          sock.onmessage = (e) ->

            switch e.type
              when 'message'
                data = JSON.parse(e.data)
                event = data._event
                $bus.$broadcast(event, data.payload)

    subscribe: (name, callback) ->
      $bus.$on name, (e, data) ->
        $scope.$apply ->
          callback(data)
]

