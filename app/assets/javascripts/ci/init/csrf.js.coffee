CI.config ["$httpProvider",
  ($httpProvider) ->
    token = _.find document.getElementsByTagName("meta"), (it) ->
      it.name == 'csrf-token'
    if token
      $httpProvider.defaults.headers.common['X-CSRF-Token'] = token.content
    $httpProvider.defaults.headers.common['Accept'] = 'application/json'
]
