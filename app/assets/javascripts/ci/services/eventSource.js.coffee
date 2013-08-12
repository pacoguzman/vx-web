CI.service 'eventSource', [
  () ->

    eventSource = new EventSource('/events')

    {
      subscribe: (name, callback) ->
        proxy = (e) ->
          callback(JSON.parse e.data)
        eventSource.addEventListener name, proxy, false

    }

]

