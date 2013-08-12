window.eventSourceMock = () ->
  subscribed = []
  subscribe: (name, callback) ->
    subscribed.push [name, callback]
  subscriptions: () ->
    subscribed
  reset: () ->
    subscribed = []
